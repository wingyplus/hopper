defmodule Hopper.Core.Filters.ASCII85Decode do
  @moduledoc false

  # ASCII85Decode — ISO 32000-2:2020 §7.4.3

  @powers [52_200_625, 614_125, 7_225, 85, 1]

  def encode(data, _params \\ nil) do
    data
    |> do_encode([])
    |> Enum.reverse()
    |> IO.iodata_to_binary()
  end

  defp do_encode(<<>>, acc), do: ["~>" | acc]

  defp do_encode(<<0, 0, 0, 0, rest::binary>>, acc) do
    do_encode(rest, [?z | acc])
  end

  defp do_encode(<<b1, b2, b3, b4, rest::binary>>, acc) do
    value = b1 * 16_777_216 + b2 * 65_536 + b3 * 256 + b4
    do_encode(rest, [ascii85_group(value) | acc])
  end

  defp do_encode(partial, acc) do
    n = byte_size(partial)
    padded = partial <> :binary.copy(<<0>>, 4 - n)
    <<b1, b2, b3, b4>> = padded
    value = b1 * 16_777_216 + b2 * 65_536 + b3 * 256 + b4
    chars = ascii85_group(value) |> Enum.take(n + 1)
    do_encode(<<>>, [chars | acc])
  end

  defp ascii85_group(value) do
    Enum.map(@powers, fn power -> rem(div(value, power), 85) + 33 end)
  end

  def decode(data, _params \\ nil) do
    body =
      case String.split(data, "~>", parts: 2) do
        [body, _] -> body
        [body] -> body
      end

    body
    |> String.replace(~r/\s/, "")
    |> do_decode([])
    |> Enum.reverse()
    |> IO.iodata_to_binary()
  end

  defp do_decode("", acc), do: acc

  defp do_decode("z" <> rest, acc) do
    do_decode(rest, [<<0, 0, 0, 0>> | acc])
  end

  defp do_decode(<<c1, c2, c3, c4, c5, rest::binary>>, acc) do
    value =
      (c1 - 33) * 52_200_625 +
        (c2 - 33) * 614_125 +
        (c3 - 33) * 7_225 +
        (c4 - 33) * 85 +
        (c5 - 33)

    do_decode(rest, [<<value::32>> | acc])
  end

  # Partial final group: n+1 chars → n bytes, pad missing chars with 'u' (84 + 33 = 117)
  defp do_decode(chars, acc) when byte_size(chars) in 2..4 do
    n = byte_size(chars) - 1
    padded = chars <> String.duplicate("u", 5 - byte_size(chars))
    <<c1, c2, c3, c4, c5>> = padded

    value =
      (c1 - 33) * 52_200_625 +
        (c2 - 33) * 614_125 +
        (c3 - 33) * 7_225 +
        (c4 - 33) * 85 +
        (c5 - 33)

    <<result::binary-size(n), _::binary>> = <<value::32>>
    [result | acc]
  end
end
