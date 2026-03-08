defmodule Hopper.Core.Operator do
  @moduledoc false

  alias Hopper.Core.Object

  @enforce_keys [:name]
  defstruct [:name, args: []]

  @type t :: %__MODULE__{name: String.t(), args: list()}

  @doc """
  Serializes an `%Operator{}` struct to iodata.

  No-arg operators emit `"name\\n"`. Operators with arguments emit each
  argument serialized via `Object.to_iodata/1`, space-separated, followed
  by a space, the operator name, and a newline.
  """
  @spec to_iodata(t()) :: iodata()
  def to_iodata(%__MODULE__{name: name, args: []}) do
    [name, ?\n]
  end

  def to_iodata(%__MODULE__{name: name, args: args}) do
    serialized = args |> Enum.map(&Object.to_iodata/1) |> Enum.intersperse(?\s)
    [serialized, ?\s, name, ?\n]
  end
end
