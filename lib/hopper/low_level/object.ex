defmodule Hoper.LowLevel.Objects do
  @moduledoc false

  alias Hoper.LowLevel.Objects.{LitString, HexString, Array, Name, Boolean, Integer, Real}

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
end
