defmodule Hoper.Core.Objects.IndirectObject do
  @moduledoc false

  defstruct [:object_number, :generation_number, :value]
end

defimpl Hoper.Core.Object, for: Hoper.Core.Objects.IndirectObject do
  def to_iodata(%{object_number: obj_num, generation_number: gen_num, value: value}) do
    [
      # FIXME: use Object.to_iodata for integer.
      Integer.to_string(obj_num),
      ~c" ",
      # FIXME: use Object.to_iodata for integer.
      Integer.to_string(gen_num),
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
    # FIXME: use Object.to_iodata for integer.
    [Integer.to_string(obj_num), " ", Integer.to_string(gen_num), " R"]
  end
end
