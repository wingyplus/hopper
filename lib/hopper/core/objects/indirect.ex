defmodule Hoper.Core.Objects.IndirectObject do
  @moduledoc false

  defstruct [:object_number, :generation_number, :value]
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.IndirectObject do
  def to_iodata(%{object_number: obj_num, generation_number: gen_num, value: value}) do
    [
      Integer.to_string(obj_num),
      " ",
      Integer.to_string(gen_num),
      " obj\n",
      Hoper.Core.Object.to_iodata(value),
      "\nendobj"
    ]
  end
end

defmodule Hoper.Core.Objects.IndirectReference do
  @moduledoc false

  defstruct [:object_number, :generation_number]
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.IndirectReference do
  def to_iodata(%{object_number: obj_num, generation_number: gen_num}) do
    [Integer.to_string(obj_num), " ", Integer.to_string(gen_num), " R"]
  end
end
