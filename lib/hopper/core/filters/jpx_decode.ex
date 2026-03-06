defmodule Hopper.Core.Filters.JPXDecode do
  @moduledoc false

  # JPXDecode — ISO 32000-2:2020 §7.4.10 (ISO/IEC 15444-1 / ITU-T T.800)
  # Data must be pre-encoded/pre-decoded by the caller.

  def encode(data, _params \\ nil), do: data
  def decode(data, _params \\ nil), do: data
end
