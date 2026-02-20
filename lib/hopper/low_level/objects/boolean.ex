defmodule Hoper.LowLevel.Objects.Boolean do
  @moduledoc false

  defstruct [:value]

  def to_iodata(%__MODULE__{value: true}), do: "true"
  def to_iodata(%__MODULE__{value: false}), do: "false"
end
