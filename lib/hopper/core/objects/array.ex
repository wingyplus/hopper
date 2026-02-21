defmodule Hoper.Core.Objects.Array do
  @moduledoc false

  defstruct [:elements]
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.Array do
  def to_iodata(%{elements: elements}) do
    [?[, elements |> Enum.map(&Hoper.Core.Object.to_iodata/1) |> Enum.intersperse(?\s), ?]]
  end
end
