defmodule Hoper.Core.Objects.Integer do
  @moduledoc false

  defstruct [:value]
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.Integer do
  def to_iodata(%{value: value}) do
    Integer.to_string(value)
  end
end
