defmodule Hopper.Core.Objects.HexString do
  @moduledoc false

  defstruct [:string]
end

defimpl Hopper.Core.Object, for: Hopper.Core.Objects.HexString do
  def to_iodata(%{string: string}) do
    [?<, Base.encode16(string), ?>]
  end
end
