defmodule Hopper.Core.Objects.Boolean do
  @moduledoc false

  @type t :: %__MODULE__{}

  defstruct [:value]
end

defimpl Hopper.Core.Object, for: Hopper.Core.Objects.Boolean do
  def to_iodata(%{value: true}), do: "true"
  def to_iodata(%{value: false}), do: "false"
end
