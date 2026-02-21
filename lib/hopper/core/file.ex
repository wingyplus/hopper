defmodule Hoper.Core.File do
  alias Hoper.Core.{Object, Objects}
  alias Hoper.Core.Objects.IndirectObject

  defstruct [:body, :root_object_number, :id]

  @type t :: %__MODULE__{
          body: [IndirectObject.t()],
          root_object_number: pos_integer(),
          id: {binary(), binary()} | nil
        }

  @spec build(t()) :: iodata()
  def build(%__MODULE__{body: objects, root_object_number: root_object_number, id: id}) do
    {id1, id2} = id || {:crypto.strong_rand_bytes(16), :crypto.strong_rand_bytes(16)}

    hdr = header()
    hdr_size = IO.iodata_length(hdr)
    {body_iodata, offsets} = serialize_body(objects, hdr_size)
    xref_offset = hdr_size + IO.iodata_length(body_iodata)
    xref = xref_table(offsets, length(objects))
    trlr = trailer(objects, root_object_number, xref_offset, id1, id2)

    [hdr, body_iodata, xref, trlr]
  end

  # TODO: implements comment (section 7.2.4)
  defp header, do: ["%PDF-2.0", ?\n, "%\xFF\xFF\xFF\xFF", ?\n]

  defp serialize_body(objects, initial_offset) do
    Enum.reduce(objects, {[], [], initial_offset}, fn obj, {io_acc, off_acc, offset} ->
      obj_io = [Object.to_iodata(obj), "\n"]
      obj_size = IO.iodata_length(obj_io)
      {[io_acc, obj_io], [{obj.object_number, offset} | off_acc], offset + obj_size}
    end)
    |> then(fn {io, offsets, _} -> {io, Enum.reverse(offsets)} end)
  end

  defp xref_table(offsets, object_count) do
    free = xref_entry(0, 65535, "f")

    in_use =
      offsets
      |> Enum.sort_by(fn {num, _} -> num end)
      |> Enum.map(fn {_, offset} -> xref_entry(offset, 0, "n") end)

    ["xref\n0 ", Integer.to_string(object_count + 1), "\n", free | in_use]
  end

  defp xref_entry(offset, gen, type) do
    o = offset |> Integer.to_string() |> String.pad_leading(10, "0")
    g = gen |> Integer.to_string() |> String.pad_leading(5, "0")
    [o, " ", g, " ", type, " \n"]
  end

  defp trailer(objects, root_obj_num, xref_offset, id1, id2) do
    dict =
      Objects.dictionary([
        {"Size", length(objects) + 1},
        {"Root", Objects.indirect_reference(root_obj_num, 0)},
        {"ID", Objects.array([Objects.hex_string(id1), Objects.hex_string(id2)])}
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
