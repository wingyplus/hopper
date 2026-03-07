defmodule Hopper.Core.Filters.RunLengthDecode do
  @moduledoc false

  # RunLengthDecode — ISO 32000-2:2020 §7.4.6
  #
  # Encoded format (reader / decode direction):
  #   length byte 0–127   → copy the next (length + 1) bytes literally
  #   length byte 129–255 → repeat the next byte (257 - length) times
  #   length byte 128     → end of data

  @eod 128

  # ---------------------------------------------------------------------------
  # Encode
  # ---------------------------------------------------------------------------

  @doc false
  def encode(data, _params \\ nil) when is_binary(data) do
    do_encode(data, [])
  end

  # Base case: end of data — emit EOD marker.
  defp do_encode(<<>>, acc), do: [acc, @eod]

  defp do_encode(<<byte, _::binary>> = data, acc) do
    run_len = count_run(data, byte, 0)

    if run_len >= 2 do
      # Run of identical bytes.
      remaining = binary_part(data, run_len, byte_size(data) - run_len)
      new_acc = emit_runs(run_len, byte, acc)
      do_encode(remaining, new_acc)
    else
      # Literal sequence: walk forward until we see two identical bytes in a row.
      lit_len = count_literals(data, 0)
      remaining = binary_part(data, lit_len, byte_size(data) - lit_len)
      new_acc = emit_literals(data, lit_len, acc)
      do_encode(remaining, new_acc)
    end
  end

  # Count how many leading bytes equal `byte`.
  defp count_run(<<b, rest::binary>>, b, n), do: count_run(rest, b, n + 1)
  defp count_run(_binary, _b, n), do: n

  # Count the length of the next literal sequence (stops at a 2+ run or 128-byte cap).
  # A literal sequence ends when two consecutive identical bytes appear — that signals
  # the start of a run that should be encoded separately.
  defp count_literals(<<>>, n), do: n
  defp count_literals(<<_>>, n), do: n + 1

  defp count_literals(<<b, b, _::binary>>, n) when n > 0, do: n

  defp count_literals(_, 128), do: 128

  defp count_literals(<<_b, rest::binary>>, n), do: count_literals(rest, n + 1)

  # Emit one or more run-length (control + byte) pairs, splitting at a max chunk of 128.
  defp emit_runs(0, _byte, acc), do: acc

  defp emit_runs(n, byte, acc) when n > 128 do
    emit_runs(n - 128, byte, [acc, <<257 - 128, byte>>])
  end

  defp emit_runs(n, byte, acc) do
    [acc, <<257 - n, byte>>]
  end

  # Emit one literal chunk: a length-minus-one header byte followed by the raw bytes.
  defp emit_literals(data, lit_len, acc) do
    [acc, <<lit_len - 1>>, binary_part(data, 0, lit_len)]
  end

  # ---------------------------------------------------------------------------
  # Decode
  # ---------------------------------------------------------------------------

  @doc false
  def decode(data, _params \\ nil) when is_binary(data) do
    do_decode(data, []) |> :erlang.iolist_to_binary()
  end

  # EOD byte terminates the stream.
  defp do_decode(<<@eod, _::binary>>, acc), do: acc
  defp do_decode(<<>>, acc), do: acc

  # Literal run: copy the next (length + 1) bytes verbatim.
  defp do_decode(<<length, rest::binary>>, acc) when length <= 127 do
    count = length + 1
    chunk = binary_part(rest, 0, count)
    remaining = binary_part(rest, count, byte_size(rest) - count)
    do_decode(remaining, [acc, chunk])
  end

  # Repeated run: repeat the next byte (257 - length) times.
  defp do_decode(<<length, byte, rest::binary>>, acc) when length >= 129 do
    count = 257 - length
    do_decode(rest, [acc, :binary.copy(<<byte>>, count)])
  end
end
