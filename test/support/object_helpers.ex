defmodule Hoper.ObjectHelpers do
  alias Hoper.Core.Object

  def render(obj), do: IO.iodata_to_binary(Object.to_iodata(obj))
end
