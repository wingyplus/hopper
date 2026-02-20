defmodule Hoper.LowLevel.Objects.Real do
  @moduledoc false

  defstruct [:value]

  def to_iodata(%__MODULE__{value: value}) do
    Float.to_string(value)
  end
end
