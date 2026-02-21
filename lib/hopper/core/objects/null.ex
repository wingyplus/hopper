defmodule Hoper.Core.Objects.Null do
  @moduledoc false

  defstruct []
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.Null do
  def to_iodata(%Hoper.Core.Objects.Null{}), do: "null"
end
