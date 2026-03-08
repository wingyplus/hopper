defprotocol Hopper.Core.Object do
  @doc false
  def to_iodata(object)
end

defimpl Hopper.Core.Object, for: Integer do
  def to_iodata(value), do: Integer.to_string(value)
end

defimpl Hopper.Core.Object, for: Float do
  def to_iodata(value), do: Float.to_string(value)
end

defimpl Hopper.Core.Object, for: Atom do
  def to_iodata(nil), do: "null"
end

defimpl Hopper.Core.Object, for: List do
  def to_iodata(elements) do
    [?[, elements |> Enum.map(&Hopper.Core.Object.to_iodata/1) |> Enum.intersperse(?\s), ?]]
  end
end

defmodule Hopper.Core.Objects do
  @moduledoc false

  alias Hopper.Core.Objects.{
    LitString,
    HexString,
    Name,
    Boolean,
    Dictionary,
    Stream,
    IndirectObject,
    IndirectReference
  }

  @doc false
  def boolean(value) when is_boolean(value) do
    %Boolean{value: value}
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
  def name(name) when is_binary(name) do
    %Name{name: name}
  end

  @doc false
  def dictionary(entries) when is_list(entries) or is_map(entries) do
    %Dictionary{
      entries: Enum.map(entries, fn {key, value} -> {name(normalize_key(key)), value} end)
    }
  end

  @doc false
  def indirect_object(object_number, generation_number \\ 0, value)
      when is_integer(object_number) and object_number > 0 and
             is_integer(generation_number) and generation_number >= 0 do
    %IndirectObject{
      object_number: object_number,
      generation_number: generation_number,
      value: value
    }
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
      dictionary: dictionary(entries),
      data: data
    }
  end

  @doc false
  def stream(entries, operators)
      when (is_list(entries) or is_map(entries)) and is_list(operators) do
    data =
      operators
      |> Enum.map(&Hopper.Core.Operator.to_iodata/1)
      |> IO.iodata_to_binary()

    stream(entries, data)
  end

  defp normalize_key(key) when is_binary(key), do: key
  defp normalize_key(key) when is_atom(key), do: Atom.to_string(key)
end
