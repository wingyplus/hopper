defmodule Hoper.Core.Objects.Boolean do
  @moduledoc false

  defstruct [:value]
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.Boolean do
  def to_iodata(%{value: true}), do: "true"
  def to_iodata(%{value: false}), do: "false"
end
