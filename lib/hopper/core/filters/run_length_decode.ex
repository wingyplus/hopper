defmodule Hopper.Core.Filters.RunLengthDecode do
  @moduledoc false

  # RunLengthDecode — ISO 32000-2:2020 §7.4.6
  #
  # Encoded format (reader / decode direction):
  #   length byte 0–127   → copy the next (length + 1) bytes literally
  #   length byte 129–255 → repeat the next byte (257 - length) times
  #   length byte 128     → end of data

  def encode(data, _params \\ nil) do
    data
    |> :binary.bin_to_list()
    |> do_encode([])
    |> Enum.reverse()
    |> List.flatten()
    |> :binary.list_to_bin()
  end

  defp do_encode([], acc), do: [[128] | acc]

  defp do_encode([byte | _] = input, acc) do
    run_len = count_run(input, byte, 0)

    if run_len >= 2 do
      remaining = Enum.drop(input, run_len)

      new_acc =
        run_len
        |> split_chunks(128)
        |> Enum.reduce(acc, fn n, a -> [[257 - n, byte] | a] end)

      do_encode(remaining, new_acc)
    else
      {literals, remaining} = take_literals(input, [])

      new_acc =
        literals
        |> Enum.chunk_every(128)
        |> Enum.reduce(acc, fn chunk, a -> [[length(chunk) - 1 | chunk] | a] end)

      do_encode(remaining, new_acc)
    end
  end

  defp count_run([byte | rest], byte, n), do: count_run(rest, byte, n + 1)
  defp count_run(_, _byte, n), do: n

  defp split_chunks(n, max) when n <= max, do: [n]
  defp split_chunks(n, max), do: [max | split_chunks(n - max, max)]

  defp take_literals([], acc), do: {Enum.reverse(acc), []}
  defp take_literals([b, b | _] = rest, acc), do: {Enum.reverse(acc), rest}
  defp take_literals([byte | rest], acc), do: take_literals(rest, [byte | acc])

  def decode(data, _params \\ nil) do
    data
    |> :binary.bin_to_list()
    |> do_decode([])
    |> Enum.reverse()
    |> List.flatten()
    |> :binary.list_to_bin()
  end

  defp do_decode([128 | _], acc), do: acc

  defp do_decode([length | rest], acc) when length <= 127 do
    count = length + 1
    {bytes, remaining} = Enum.split(rest, count)
    do_decode(remaining, [bytes | acc])
  end

  defp do_decode([length | [byte | rest]], acc) when length >= 129 do
    count = 257 - length
    do_decode(rest, [List.duplicate(byte, count) | acc])
  end
end
