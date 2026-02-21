defmodule Hopper.Core.Objects.Stream do
  @moduledoc false

  defstruct [:dictionary, :data]
end

defimpl Hopper.Core.Object, for: Hopper.Core.Objects.Stream do
  def to_iodata(%{dictionary: %Hopper.Core.Objects.Dictionary{entries: entries}, data: data}) do
    length_entry = {%Hopper.Core.Objects.Name{name: "Length"}, byte_size(data)}
    dict_with_length = %Hopper.Core.Objects.Dictionary{entries: [length_entry | entries]}
    [Hopper.Core.Object.to_iodata(dict_with_length), "\nstream\n", data, "\nendstream"]
  end
end
