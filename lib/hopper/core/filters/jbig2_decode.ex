defmodule Hopper.Core.Filters.JBIG2Decode do
  @moduledoc false

  # JBIG2Decode — ISO 32000-2:2020 §7.4.8 (ISO/IEC 11544)
  # Data must be pre-encoded/pre-decoded by the caller.

  def encode(data, _params \\ nil), do: data
  def decode(data, _params \\ nil), do: data
end
