defmodule Hoper.LowLevel.Objects do
  @moduledoc false

  import Bitwise

  # Literal strings object.
  @doc false
  def lit_string(string) when is_binary(string) do
    [?(, escape_lit_string(string), ?)]
  end

  # Hexadecimal strings object.
  @doc false
  def hex_string(string) when is_binary(string) do
    [?<, Base.encode16(string), ?>]
  end

  # Name objects.
  @doc false
  def name(name) when is_binary(name) do
    [?/ | encode_name(name)]
  end

  defp encode_name(<<>>), do: []

  defp encode_name(<<byte, rest::binary>>)
       when byte in [?#, ?(, ?), ?<, ?>, ?[, ?], ?{, ?}, ?/, ?%] do
    [?#, hex(byte >>> 4), hex(byte &&& 0x0F) | encode_name(rest)]
  end

  defp encode_name(<<byte, rest::binary>>) when byte < 0x21 or byte > 0x7E do
    [?#, hex(byte >>> 4), hex(byte &&& 0x0F) | encode_name(rest)]
  end

  defp encode_name(<<byte, rest::binary>>), do: [byte | encode_name(rest)]

  defp hex(n) when n < 10, do: ?0 + n
  defp hex(n), do: ?A + n - 10

  defp escape_lit_string(<<>>), do: []
  defp escape_lit_string(<<?\n, rest::binary>>), do: [?\\, ?n | escape_lit_string(rest)]
  defp escape_lit_string(<<?\r, rest::binary>>), do: [?\\, ?r | escape_lit_string(rest)]
  defp escape_lit_string(<<?\t, rest::binary>>), do: [?\\, ?t | escape_lit_string(rest)]
  defp escape_lit_string(<<?\b, rest::binary>>), do: [?\\, ?b | escape_lit_string(rest)]
  defp escape_lit_string(<<?\f, rest::binary>>), do: [?\\, ?f | escape_lit_string(rest)]
  defp escape_lit_string(<<?\\, rest::binary>>), do: [?\\, ?\\ | escape_lit_string(rest)]
  defp escape_lit_string(<<?( , rest::binary>>), do: [?\\, ?( | escape_lit_string(rest)]
  defp escape_lit_string(<<?), rest::binary>>), do: [?\\, ?) | escape_lit_string(rest)]
  defp escape_lit_string(<<byte, rest::binary>>), do: [byte | escape_lit_string(rest)]
end
