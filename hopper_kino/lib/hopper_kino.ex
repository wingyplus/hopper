defmodule HopperKino do
  @moduledoc """
  Kino integration for the Hopper PDF library.

  ## Usage

  Explicitly create a viewer widget from a file:

      HopperKino.new(file)
  """

  @spec new(Hopper.Core.File.t()) :: Kino.JS.t()
  def new(%Hopper.Core.File{} = file) do
    pdf_binary = file |> Hopper.Core.File.build() |> IO.iodata_to_binary()
    HopperKino.PDF.new(pdf_binary)
  end
end
