defmodule Hopper.Core.File do
  alias Hopper.Core.Object
  alias Hopper.Core.Objects
  alias Hopper.Core.Objects.IndirectObject
  alias Hopper.Core.Lexical

  defstruct [:version, :body, :id, root_object: {1, 0}]

  @type t :: %__MODULE__{
          version: String.t(),
          body: [IndirectObject.t()],
          root_object: {pos_integer(), non_neg_integer()},
          id: {binary(), binary()} | nil
        }

  @spec build(t()) :: iodata()
  def build(%__MODULE__{version: version, body: objects, root_object: {root_obj_num, root_gen_num}, id: id}) do
    id = id || {:crypto.strong_rand_bytes(16), :crypto.strong_rand_bytes(16)}

    hdr = header(version)
    hdr_size = IO.iodata_length(hdr)
    {body_iodata, offsets, xref_offset} = serialize_body(objects, hdr_size)
    object_count = length(objects)
    xref = xref_table(offsets, object_count)
    trlr = trailer(object_count, {root_obj_num, root_gen_num}, xref_offset, id)

    [hdr, body_iodata, xref, trlr]
  end

  defp header(version), do: ["%PDF-", version, ?\n, Lexical.comment("\xFF\xFF\xFF\xFF"), ?\n]

  defp serialize_body(objects, initial_offset) do
    Enum.reduce(objects, {[], [], initial_offset}, fn obj, {io_acc, off_acc, offset} ->
      obj_io = [Object.to_iodata(obj), ?\n]
      obj_size = IO.iodata_length(obj_io)
      {[io_acc, obj_io], [{obj.object_number, offset} | off_acc], offset + obj_size}
    end)
    |> then(fn {io, offsets, final_offset} -> {io, Enum.reverse(offsets), final_offset} end)
  end

  defp xref_table(offsets, object_count) do
    free = xref_entry(0, 65535, "f")

    in_use =
      offsets
      |> Enum.sort_by(fn {num, _} -> num end)
      |> Enum.map(fn {_, offset} -> xref_entry(offset, 0, "n") end)

    [
      "xref",
      ?\n,
      Object.to_iodata(0),
      ~c" ",
      Object.to_iodata(object_count + 1),
      ?\n,
      free | in_use
    ]
  end

  defp xref_entry(offset, gen, type) do
    o = offset |> Integer.to_string() |> String.pad_leading(10, "0")
    g = gen |> Integer.to_string() |> String.pad_leading(5, "0")
    [o, ~c" ", g, ~c" ", type, ~c" ", ?\n]
  end

  defp trailer(object_count, {root_obj_num, root_gen_num}, xref_offset, {id1, id2}) do
    dict =
      Objects.dictionary([
        {"Size", object_count + 1},
        {"Root", Objects.indirect_reference(root_obj_num, root_gen_num)},
        {"ID", [Objects.hex_string(id1), Objects.hex_string(id2)]}
      ])

    [
      "trailer",
      ?\n,
      Object.to_iodata(dict),
      ?\n,
      "startxref",
      ?\n,
      Object.to_iodata(xref_offset),
      ?\n,
      "%%EOF",
      ?\n
    ]
  end
end
