defmodule Hoper.LowLevel.Objects do
  @moduledoc false

  alias Hoper.LowLevel.Objects.{LitString, HexString, Array, Name}

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
