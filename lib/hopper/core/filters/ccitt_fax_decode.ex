defmodule Hopper.Core.Filters.CCITTFaxDecode do
  @moduledoc false

  # CCITTFaxDecode — ISO 32000-2:2020 §7.4.7 (ITU-T T.4 / T.6)
  # Data must be pre-encoded/pre-decoded by the caller.

  def encode(data, _params \\ nil), do: data
  def decode(data, _params \\ nil), do: data
end
