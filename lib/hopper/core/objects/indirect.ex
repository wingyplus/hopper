defmodule Hoper.Core.Objects.IndirectObject do
  @moduledoc false

  defstruct [:object_number, :generation_number, :value]
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.IndirectObject do
  def to_iodata(%{object_number: obj_num, generation_number: gen_num, value: value}) do
    [
      Hoper.Core.Object.to_iodata(obj_num),
      ~c" ",
      Hoper.Core.Object.to_iodata(gen_num),
      ~c" ",
      "obj",
      ?\n,
      Hoper.Core.Object.to_iodata(value),
      ?\n,
      "endobj"
    ]
  end
end

defmodule Hoper.Core.Objects.IndirectReference do
  @moduledoc false

  defstruct [:object_number, :generation_number]
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.IndirectReference do
  def to_iodata(%{object_number: obj_num, generation_number: gen_num}) do
    [Hoper.Core.Object.to_iodata(obj_num), " ", Hoper.Core.Object.to_iodata(gen_num), " R"]
  end
end
