defmodule Hopper.Core.Filter do
  @moduledoc false

  alias Hopper.Core.Objects.Name


  @doc """
  Encodes data through the specified filter(s) for writing into a PDF stream.

  Filter names follow PDF convention (ending in "Decode") because they describe
  the reader's decoding direction. As a writer, this function encodes in the
  inverse direction.

  For a list of filters, the writer encodes in reverse order of the array
  (since readers decode in forward array order).
  """
  def encode(data, filter, parms \\ nil)

  def encode(data, %Name{name: name}, parms) do
    module!(name).encode(data, parms)
  end

  def encode(data, filters, parms_value) when is_list(filters) do
    parms_list =
      case parms_value do
        nil -> List.duplicate(nil, length(filters))
        list when is_list(list) -> list
        single -> [single | List.duplicate(nil, length(filters) - 1)]
      end

    # Apply in reverse order: writer encodes opposite of reader's decode order
    filters
    |> Enum.zip(parms_list)
    |> Enum.reverse()
    |> Enum.reduce(data, fn {%Name{name: name}, param}, acc ->
      module!(name).encode(acc, param)
    end)
  end

  @doc """
  Decodes data through the specified filter(s) for reading from a PDF stream.

  For a list of filters, decodes in forward array order (matching PDF reader convention).
  """
  def decode(data, filter, parms \\ nil)

  def decode(data, %Name{name: name}, parms) do
    module!(name).decode(data, parms)
  end

  def decode(data, filters, parms_value) when is_list(filters) do
    parms_list =
      case parms_value do
        nil -> List.duplicate(nil, length(filters))
        list when is_list(list) -> list
        single -> [single | List.duplicate(nil, length(filters) - 1)]
      end

    filters
    |> Enum.zip(parms_list)
    |> Enum.reduce(data, fn {%Name{name: name}, param}, acc ->
      module!(name).decode(acc, param)
    end)
  end

  defp module!("ASCIIHexDecode"), do: Hopper.Core.Filters.ASCIIHexDecode
  defp module!("ASCII85Decode"), do: Hopper.Core.Filters.ASCII85Decode
  defp module!("FlateDecode"), do: Hopper.Core.Filters.FlateDecode
  defp module!("RunLengthDecode"), do: Hopper.Core.Filters.RunLengthDecode
  defp module!("LZWDecode"), do: Hopper.Core.Filters.LZWDecode
  defp module!("CCITTFaxDecode"), do: Hopper.Core.Filters.CCITTFaxDecode
  defp module!("JBIG2Decode"), do: Hopper.Core.Filters.JBIG2Decode
  defp module!("DCTDecode"), do: Hopper.Core.Filters.DCTDecode
  defp module!("JPXDecode"), do: Hopper.Core.Filters.JPXDecode
  defp module!("Crypt"), do: Hopper.Core.Filters.Crypt
end
