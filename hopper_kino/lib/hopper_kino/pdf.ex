defmodule HopperKino.PDF do
  @moduledoc false

  use Kino.JS

  @spec new(binary()) :: Kino.JS.t()
  def new(pdf_binary) when is_binary(pdf_binary) do
    Kino.JS.new(__MODULE__, Base.encode64(pdf_binary))
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
