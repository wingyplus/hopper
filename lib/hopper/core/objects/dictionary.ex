defmodule Hoper.Core.Objects.Dictionary do
  @moduledoc false

  alias Hoper.Core.Objects.{LitString, HexString, Array, Name, Boolean, Real}
  alias Hoper.Core.Objects.Integer, as: IntegerObject

  defstruct [:entries]

  def to_iodata(%__MODULE__{entries: []}) do
    "<<>>"
  end

  def to_iodata(%__MODULE__{entries: entries}) do
    pairs =
      entries
      |> Enum.map(fn {key, value} ->
        [Name.to_iodata(key), ?\s, value_to_iodata(value)]
      end)
      |> Enum.intersperse(?\s)

    [?<, ?<, ?\s, pairs, ?\s, ?>, ?>]
  end

  defp value_to_iodata(%__MODULE__{} = dict), do: to_iodata(dict)
  defp value_to_iodata(%Boolean{} = b), do: Boolean.to_iodata(b)
  defp value_to_iodata(%IntegerObject{} = i), do: IntegerObject.to_iodata(i)
  defp value_to_iodata(%Real{} = r), do: Real.to_iodata(r)
  defp value_to_iodata(%LitString{} = s), do: LitString.to_iodata(s)
  defp value_to_iodata(%HexString{} = s), do: HexString.to_iodata(s)
  defp value_to_iodata(%Name{} = n), do: Name.to_iodata(n)
  defp value_to_iodata(%Array{} = a), do: Array.to_iodata(a)
end
