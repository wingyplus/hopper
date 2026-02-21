defmodule Hoper.LowLevel.Objects.Stream do
  @moduledoc false

  alias Hoper.LowLevel.Objects.{Dictionary, Name}
  alias Hoper.LowLevel.Objects.Integer, as: IntegerObject

  defstruct [:dictionary, :data]

  def to_iodata(%__MODULE__{dictionary: %Dictionary{entries: entries}, data: data}) do
    length_entry = {%Name{name: "Length"}, %IntegerObject{value: byte_size(data)}}
    dict_with_length = %Dictionary{entries: [length_entry | entries]}
    [Dictionary.to_iodata(dict_with_length), "\nstream\n", data, "\nendstream"]
  end
end
