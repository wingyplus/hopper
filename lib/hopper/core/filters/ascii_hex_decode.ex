defmodule Hopper.Core.Filters.ASCIIHexDecode do
  @moduledoc false

  # ASCIIHexDecode — ISO 32000-2:2020 §7.4.2

  def encode(data, _params \\ nil) do
    Base.encode16(data) <> ">"
  end

  def decode(data, _params \\ nil) do
    hex =
      data
      |> String.replace(~r/\s/, "")
      |> String.trim_trailing(">")

    Base.decode16!(hex)
  end
end
