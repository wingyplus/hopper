defmodule Hopper.Core.Filters.Crypt do
  @moduledoc false

  # Crypt — ISO 32000-2:2020 §7.4.11
  # Data must be pre-encoded/pre-decoded by the caller.

  def encode(data, _params \\ nil), do: data
  def decode(data, _params \\ nil), do: data
end
