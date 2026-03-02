  defmodule Hopper.Kino do
    @moduledoc """
    Kino integration for the Hopper PDF library.

    ## Usage

    Explicitly create a viewer widget from a file:

        Hopper.Kino.new(file)
    """

    use Kino.JS

    @spec new(Hopper.Core.File.t()) :: Kino.JS.t()
    def new(%Hopper.Core.File{} = file) do
      pdf =
        file
        |> Hopper.Core.File.build()
        |> IO.iodata_to_binary()

      Kino.JS.new(__MODULE__, Base.encode64(pdf))
    end

    asset "main.js" do
      """
      import EmbedPDF from 'https://cdn.jsdelivr.net/npm/@embedpdf/snippet@2/dist/embedpdf.js';

      export async function init(ctx, pdfBase64) {
        const container = document.createElement("div");
        container.style.height = "600px";
        ctx.root.appendChild(container);

        const pdfBytes = Uint8Array.from(atob(pdfBase64), c => c.charCodeAt(0));
        const pdfBlob = new Blob([pdfBytes], { type: "application/pdf" });
        const pdfUrl = URL.createObjectURL(pdfBlob);

        EmbedPDF.init({
          type: 'container',
          target: container,
          src: pdfUrl,
          theme: { preference: 'system' },
          disabledCategories: [
            'annotation', 
            'redaction', 
            'document-open', 
            'document-close', 
            'document-print', 
            'document-export', 
          ]
        });
      }
      """
    end
  end

  defimpl Kino.Render, for: Hopper.Core.File do
    def to_livebook(file) do
      Hopper.Kino.new(file)
    end
  end
