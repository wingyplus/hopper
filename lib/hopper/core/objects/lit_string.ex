defmodule Hoper.Core.Objects.LitString do
  @moduledoc false

  defstruct [:string]
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.LitString do
  def to_iodata(%{string: string}) do
    [?(, escape(string), ?)]
  end

  defp escape(<<>>), do: []
  defp escape(<<?\n, rest::binary>>), do: [?\\, ?n | escape(rest)]
  defp escape(<<?\r, rest::binary>>), do: [?\\, ?r | escape(rest)]
  defp escape(<<?\t, rest::binary>>), do: [?\\, ?t | escape(rest)]
  defp escape(<<?\b, rest::binary>>), do: [?\\, ?b | escape(rest)]
  defp escape(<<?\f, rest::binary>>), do: [?\\, ?f | escape(rest)]
  defp escape(<<?\\, rest::binary>>), do: [?\\, ?\\ | escape(rest)]
  defp escape(<<?( , rest::binary>>), do: [?\\, ?( | escape(rest)]
  defp escape(<<?), rest::binary>>), do: [?\\, ?) | escape(rest)]
  defp escape(<<byte, rest::binary>>), do: [byte | escape(rest)]
end
