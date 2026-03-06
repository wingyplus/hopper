defmodule Hopper.Core.Objects.Stream do
  @moduledoc false

  defstruct [:dictionary, :data]
end

defimpl Hopper.Core.Object, for: Hopper.Core.Objects.Stream do
  alias Hopper.Core.Filter
  alias Hopper.Core.Objects.{Dictionary, Name}

  def to_iodata(%{dictionary: %Dictionary{entries: entries}, data: data}) do
    encoded_data = apply_filters(data, entries)
    length_entry = {%Name{name: "Length"}, byte_size(encoded_data)}
    dict_with_length = %Dictionary{entries: [length_entry | entries]}
    [Hopper.Core.Object.to_iodata(dict_with_length), "\nstream\n", encoded_data, "\nendstream"]
  end

  defp apply_filters(data, entries) do
    filter = find_entry(entries, "Filter")
    parms = find_entry(entries, "DecodeParms")

    case filter do
      nil -> data
      f -> Filter.encode(data, f, parms)
    end
  end

  defp find_entry(entries, key_name) do
    Enum.find_value(entries, fn
      {%Name{name: ^key_name}, value} -> value
      _ -> nil
    end)
  end
end
