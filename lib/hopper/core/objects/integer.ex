defmodule Hoper.Core.Objects.Integer do
  @moduledoc false

  defstruct [:value]

  def to_iodata(%__MODULE__{value: value}) do
    Integer.to_string(value)
  end
end
