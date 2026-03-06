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
    encode_single(data, name, parms)
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
      encode_single(acc, name, param)
    end)
  end

  # ---------------------------------------------------------------------------
  # FlateDecode — ISO 32000-2:2020 §7.4.5
  # Encoding: RFC 1950 (ZLIB Compressed Data Format Specification)
  #           RFC 1951 (DEFLATE Compressed Data Format Specification)
  # ---------------------------------------------------------------------------

  defp encode_single(data, "FlateDecode", _params) do
    :zlib.compress(data)
  end

  # ---------------------------------------------------------------------------
  # ASCIIHexDecode — ISO 32000-2:2020 §7.4.2
  # ---------------------------------------------------------------------------

  defp encode_single(data, "ASCIIHexDecode", _params) do
    Base.encode16(data) <> ">"
  end

  # ---------------------------------------------------------------------------
  # ASCII85Decode — ISO 32000-2:2020 §7.4.3
  # ---------------------------------------------------------------------------

  defp encode_single(data, "ASCII85Decode", _params) do
    encode_ascii85(data)
  end

  # ---------------------------------------------------------------------------
  # RunLengthDecode — ISO 32000-2:2020 §7.4.6
  # ---------------------------------------------------------------------------

  defp encode_single(data, "RunLengthDecode", _params) do
    encode_run_length(data)
  end

  # ---------------------------------------------------------------------------
  # Pass-through filters — data must be pre-encoded by the caller
  #
  # LZWDecode      — ISO 32000-2:2020 §7.4.4
  # CCITTFaxDecode — ISO 32000-2:2020 §7.4.7  (ITU-T T.4 / T.6)
  # JBIG2Decode    — ISO 32000-2:2020 §7.4.8  (ISO/IEC 11544)
  # DCTDecode      — ISO 32000-2:2020 §7.4.9  (ISO/IEC 10918-1 / ITU-T T.81)
  # JPXDecode      — ISO 32000-2:2020 §7.4.10 (ISO/IEC 15444-1 / ITU-T T.800)
  # Crypt          — ISO 32000-2:2020 §7.4.11
  # ---------------------------------------------------------------------------

  defp encode_single(data, filter, _params)
       when filter in [
              "LZWDecode",
              "CCITTFaxDecode",
              "JBIG2Decode",
              "DCTDecode",
              "JPXDecode",
              "Crypt"
            ] do
    data
  end

  # ===========================================================================
  # ASCII85 encoding
  # ===========================================================================

  # Powers of 85 (index 0 = most significant): 85^4, 85^3, 85^2, 85^1, 85^0
  @ascii85_powers [52_200_625, 614_125, 7_225, 85, 1]

  defp encode_ascii85(data) do
    data
    |> do_ascii85([])
    |> Enum.reverse()
    |> IO.iodata_to_binary()
  end

  # Base case: append the EOD marker "~>"
  defp do_ascii85(<<>>, acc), do: ["~>" | acc]

  # Special case: four zero bytes → single 'z'
  defp do_ascii85(<<0, 0, 0, 0, rest::binary>>, acc) do
    do_ascii85(rest, [?z | acc])
  end

  # Full 4-byte group → 5 ASCII chars
  defp do_ascii85(<<b1, b2, b3, b4, rest::binary>>, acc) do
    value = b1 * 16_777_216 + b2 * 65_536 + b3 * 256 + b4
    do_ascii85(rest, [ascii85_group(value) | acc])
  end

  # Partial final group: pad to 4 bytes, encode, emit only n+1 chars
  defp do_ascii85(partial, acc) do
    n = byte_size(partial)
    padded = partial <> :binary.copy(<<0>>, 4 - n)
    <<b1, b2, b3, b4>> = padded
    value = b1 * 16_777_216 + b2 * 65_536 + b3 * 256 + b4
    chars = ascii85_group(value) |> Enum.take(n + 1)
    do_ascii85(<<>>, [chars | acc])
  end

  defp ascii85_group(value) do
    Enum.map(@ascii85_powers, fn power -> rem(div(value, power), 85) + 33 end)
  end

  # ===========================================================================
  # Run-Length encoding
  # ===========================================================================
  #
  # Format of encoded output (reader perspective / "decode" direction):
  #   length byte 0–127  → copy the next (length + 1) bytes literally
  #   length byte 129–255 → repeat the next byte (257 - length) times
  #   length byte 128    → end of data
  #
  # So for encoding (writing), we emit:
  #   (run_count - 1 + 128)  →  actually (257 - run_count) for a run
  #   (literal_count - 1)    for a literal sequence
  #   128 at the end

  defp encode_run_length(data) do
    data
    |> :binary.bin_to_list()
    |> do_run_length([])
    |> Enum.reverse()
    |> List.flatten()
    |> :binary.list_to_bin()
  end

  defp do_run_length([], acc), do: [[128] | acc]

  defp do_run_length([byte | _] = input, acc) do
    run_len = count_run(input, byte, 0)

    if run_len >= 2 do
      remaining = Enum.drop(input, run_len)

      new_acc =
        run_len
        |> split_chunks(128)
        |> Enum.reduce(acc, fn n, a -> [[257 - n, byte] | a] end)

      do_run_length(remaining, new_acc)
    else
      {literals, remaining} = take_literals(input, [])

      new_acc =
        literals
        |> Enum.chunk_every(128)
        |> Enum.reduce(acc, fn chunk, a -> [[length(chunk) - 1 | chunk] | a] end)

      do_run_length(remaining, new_acc)
    end
  end

  # Count how many consecutive identical bytes start the list
  defp count_run([byte | rest], byte, n), do: count_run(rest, byte, n + 1)
  defp count_run(_, _byte, n), do: n

  # Split a count into a list of chunk sizes, each ≤ max
  defp split_chunks(n, max) when n <= max, do: [n]
  defp split_chunks(n, max), do: [max | split_chunks(n - max, max)]

  # Collect literal bytes until a run of 2+ identical bytes starts
  defp take_literals([], acc), do: {Enum.reverse(acc), []}
  defp take_literals([b, b | _] = rest, acc), do: {Enum.reverse(acc), rest}
  defp take_literals([byte | rest], acc), do: take_literals(rest, [byte | acc])
end
