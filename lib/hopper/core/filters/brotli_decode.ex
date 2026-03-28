defmodule Hopper.Core.Filters.BrotliDecode do
  @moduledoc false

  # BrotliDecode — ISO 32000-2:2020 Amendment 2
  # Encoding: RFC 7932 (Brotli)

  def encode(data, _params \\ nil) do
    {:ok, compressed} = :brotli.encode(data)
    compressed
  end

  def decode(data, _params \\ nil) do
    {:ok, decompressed} = :brotli.decode(data)
    decompressed
  end
end
