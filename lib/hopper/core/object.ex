defprotocol Hoper.Core.Object do
  @doc false
  def to_iodata(object)
end

defmodule Hoper.Core.Objects do
  @moduledoc false

  alias Hoper.Core.Objects.{LitString, HexString, Array, Name, Boolean, Integer, Real, Dictionary, Stream, Null, IndirectObject, IndirectReference}

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
  def null(), do: %Null{}

  @doc false
  def indirect_object(object_number, generation_number \\ 0, value)
      when is_integer(object_number) and object_number > 0 and
             is_integer(generation_number) and generation_number >= 0 do
    %IndirectObject{object_number: object_number, generation_number: generation_number, value: value}
  end

  @doc false
  def indirect_reference(object_number, generation_number \\ 0)
      when is_integer(object_number) and object_number > 0 and
             is_integer(generation_number) and generation_number >= 0 do
    %IndirectReference{object_number: object_number, generation_number: generation_number}
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
