defmodule Hoper.LowLevel.Objects.Array do
  @moduledoc false

  alias Hoper.LowLevel.Objects.{LitString, HexString, Name}

  defstruct [:elements]

  def to_iodata(%__MODULE__{elements: elements}) do
    [?[, elements |> Enum.map(&element_to_iodata/1) |> Enum.intersperse(?\s), ?]]
  end

  defp element_to_iodata(%__MODULE__{} = array), do: to_iodata(array)
  defp element_to_iodata(%LitString{} = s), do: LitString.to_iodata(s)
  defp element_to_iodata(%HexString{} = s), do: HexString.to_iodata(s)
  defp element_to_iodata(%Name{} = n), do: Name.to_iodata(n)
end
