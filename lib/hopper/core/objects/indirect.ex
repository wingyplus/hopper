defmodule Hopper.Core.Objects.IndirectObject do
  @moduledoc false

  defstruct [:object_number, :generation_number, :value]
end

defimpl Hopper.Core.Object, for: Hopper.Core.Objects.IndirectObject do
  def to_iodata(%{object_number: obj_num, generation_number: gen_num, value: value}) do
    [
      Hopper.Core.Object.to_iodata(obj_num),
      ~c" ",
      Hopper.Core.Object.to_iodata(gen_num),
      ~c" ",
      "obj",
      ?\n,
      Hopper.Core.Object.to_iodata(value),
      ?\n,
      "endobj"
    ]
  end
end

defmodule Hopper.Core.Objects.IndirectReference do
  @moduledoc false

  @type t :: %__MODULE__{}

  defstruct [:object_number, :generation_number]
end

defimpl Hopper.Core.Object, for: Hopper.Core.Objects.IndirectReference do
  def to_iodata(%{object_number: obj_num, generation_number: gen_num}) do
    [Hopper.Core.Object.to_iodata(obj_num), " ", Hopper.Core.Object.to_iodata(gen_num), " R"]
  end
end
