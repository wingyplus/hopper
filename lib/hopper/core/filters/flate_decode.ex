defmodule Hopper.Core.Filters.FlateDecode do
  @moduledoc false

  # FlateDecode — ISO 32000-2:2020 §7.4.5
  # Encoding: RFC 1950 (ZLIB), RFC 1951 (DEFLATE)

  def encode(data, _params \\ nil) do
    :zlib.compress(data)
  end

  def decode(data, _params \\ nil) do
    :zlib.uncompress(data)
  end
end
