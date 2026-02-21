defmodule Hoper.Core.Objects.HexString do
  @moduledoc false

  defstruct [:string]
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.HexString do
  def to_iodata(%{string: string}) do
    [?<, Base.encode16(string), ?>]
  end
end
