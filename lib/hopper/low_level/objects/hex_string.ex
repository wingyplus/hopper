defmodule Hoper.LowLevel.Objects.HexString do
  @moduledoc false

  defstruct [:string]

  def to_iodata(%__MODULE__{string: string}) do
    [?<, Base.encode16(string), ?>]
  end
end
