defmodule Hopper.Core.Objects.Dictionary do
  @moduledoc false

  @type t :: %__MODULE__{}

  defstruct [:entries]
end

defimpl Hopper.Core.Object, for: Hopper.Core.Objects.Dictionary do
  def to_iodata(%{entries: []}) do
    "<<>>"
  end

  def to_iodata(%{entries: entries}) do
    pairs =
      entries
      |> Enum.map(fn {key, value} ->
        [Hopper.Core.Object.to_iodata(key), ?\s, Hopper.Core.Object.to_iodata(value)]
      end)
      |> Enum.intersperse(?\s)

    [?<, ?<, ?\s, pairs, ?\s, ?>, ?>]
  end
end
