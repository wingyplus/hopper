defprotocol Hoper.Core.Object do
  @doc false
  def to_iodata(object)
end

defmodule Hoper.Core.Objects do
  @moduledoc false

  alias Hoper.Core.Objects.{LitString, HexString, Array, Name, Boolean, Integer, Real, Dictionary, Stream}

  @doc false
  def boolean(value) when is_boolean(value) do
    %Boolean{value: value}
  end

  @doc false
  def integer(value) when is_integer(value) do
    %Integer{value: value}
  end

  @doc false
  def real(value) when is_float(value) do
    %Real{value: value}
  end

  @doc false
  def lit_string(string) when is_binary(string) do
    %LitString{string: string}
  end

  @doc false
  def hex_string(string) when is_binary(string) do
    %HexString{string: string}
  end

  @doc false
  def array(elements) when is_list(elements) do
    %Array{elements: elements}
  end

  @doc false
  def name(name) when is_binary(name) do
    %Name{name: name}
  end

  @doc false
  def dictionary(entries) when is_list(entries) or is_map(entries) do
    %Dictionary{
      entries: Enum.map(entries, fn {key, value} when is_binary(key) -> {%Name{name: key}, value} end)
    }
  end

  @doc false
  def stream(entries, data) when (is_list(entries) or is_map(entries)) and is_binary(data) do
    %Stream{
      dictionary: %Dictionary{
        entries: Enum.map(entries, fn {key, value} when is_binary(key) -> {%Name{name: key}, value} end)
      },
      data: data
    }
  end
end
