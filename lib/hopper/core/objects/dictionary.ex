defmodule Hoper.Core.Objects.Dictionary do
  @moduledoc false

  defstruct [:entries]
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.Dictionary do
  def to_iodata(%{entries: []}) do
    "<<>>"
  end

  def to_iodata(%{entries: entries}) do
    pairs =
      entries
      |> Enum.map(fn {key, value} ->
        [Hoper.Core.Object.to_iodata(key), ?\s, Hoper.Core.Object.to_iodata(value)]
      end)
      |> Enum.intersperse(?\s)

    [?<, ?<, ?\s, pairs, ?\s, ?>, ?>]
  end
end
