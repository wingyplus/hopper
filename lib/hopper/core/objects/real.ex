defmodule Hoper.Core.Objects.Real do
  @moduledoc false

  defstruct [:value]
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.Real do
  def to_iodata(%{value: value}) do
    Float.to_string(value)
  end
end
