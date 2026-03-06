defmodule Hopper.Core.Filters.LZWDecode do
  @moduledoc false

  # LZWDecode — ISO 32000-2:2020 §7.4.4
  # Data must be pre-encoded/pre-decoded by the caller.

  def encode(data, _params \\ nil), do: data
  def decode(data, _params \\ nil), do: data
end
