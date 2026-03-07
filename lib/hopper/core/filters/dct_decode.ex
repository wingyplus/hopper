defmodule Hopper.Core.Filters.DCTDecode do
  @moduledoc false

  # DCTDecode — ISO 32000-2:2020 §7.4.9 (ISO/IEC 10918-1 / ITU-T T.81)
  # Data must be pre-encoded/pre-decoded by the caller.

  def encode(data, _params \\ nil), do: data
  def decode(data, _params \\ nil), do: data
end
