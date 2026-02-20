defmodule Hoper.LowLevel.Objects do
  @moduledoc false

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
