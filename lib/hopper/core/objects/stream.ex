defmodule Hoper.Core.Objects.Stream do
  @moduledoc false

  defstruct [:dictionary, :data]
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.Stream do
  def to_iodata(%{dictionary: %Hoper.Core.Objects.Dictionary{entries: entries}, data: data}) do
    length_entry = {%Hoper.Core.Objects.Name{name: "Length"}, byte_size(data)}
    dict_with_length = %Hoper.Core.Objects.Dictionary{entries: [length_entry | entries]}
    [Hoper.Core.Object.to_iodata(dict_with_length), "\nstream\n", data, "\nendstream"]
  end
end
