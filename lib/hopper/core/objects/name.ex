defmodule Hoper.Core.Objects.Name do
  @moduledoc false

  import Bitwise

  defstruct [:name]

  def to_iodata(%__MODULE__{name: name}) do
    [?/ | encode(name)]
  end

  defp encode(<<>>), do: []

  defp encode(<<byte, rest::binary>>)
       when byte in [?#, ?(, ?), ?<, ?>, ?[, ?], ?{, ?}, ?/, ?%] do
    [?#, hex(byte >>> 4), hex(byte &&& 0x0F) | encode(rest)]
  end

  defp encode(<<byte, rest::binary>>) when byte < 0x21 or byte > 0x7E do
    [?#, hex(byte >>> 4), hex(byte &&& 0x0F) | encode(rest)]
  end

  defp encode(<<byte, rest::binary>>), do: [byte | encode(rest)]

  defp hex(n) when n < 10, do: ?0 + n
  defp hex(n), do: ?A + n - 10
end
