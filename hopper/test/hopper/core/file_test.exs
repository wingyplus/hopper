defmodule Hopper.Core.FileTest do
  use ExUnit.Case, async: true

  alias Hopper.Core.{File, Objects}

  @fixed_id {<<0xAB>> |> :binary.copy(16), <<0xCD>> |> :binary.copy(16)}

  defp render(iodata), do: IO.iodata_to_binary(iodata)

  defp extract_xref_entries(pdf) do
    {xref_pos, xref_len} = :binary.match(pdf, "xref\n")
    after_xref = binary_part(pdf, xref_pos + xref_len, byte_size(pdf) - xref_pos - xref_len)
    {nl_pos, _} = :binary.match(after_xref, "\n")
    count_line = binary_part(after_xref, 0, nl_pos)
    [_, count_str] = String.split(count_line, " ")
    count = String.to_integer(count_str)
    entries_start = xref_pos + xref_len + nl_pos + 1

    for i <- 0..(count - 1) do
      binary_part(pdf, entries_start + i * 20, 20)
    end
  end

  defp find_startxref_offset(pdf) do
    {pos, len} = :binary.match(pdf, "startxref\n")
    after_startxref = binary_part(pdf, pos + len, byte_size(pdf) - pos - len)
    {nl_pos, _} = :binary.match(after_startxref, "\n")
    after_startxref |> binary_part(0, nl_pos) |> String.to_integer()
  end

  describe "build/1" do
    test "header starts with %PDF-2.0 and binary comment marker" do
      obj = Objects.indirect_object(1, 0, 42)
      pdf = render(File.build(%File{version: "2.0", body: [obj], root_object: {1, 0}, id: @fixed_id}))
      assert String.starts_with?(pdf, "%PDF-2.0\n%\xFF\xFF\xFF\xFF\n")
    end

    test "header is exactly 15 bytes" do
      obj = Objects.indirect_object(1, 0, 42)
      pdf = render(File.build(%File{version: "2.0", body: [obj], root_object: {1, 0}, id: @fixed_id}))
      assert binary_part(pdf, 0, 15) == "%PDF-2.0\n%\xFF\xFF\xFF\xFF\n"
    end

    test "ends with %%EOF" do
      obj = Objects.indirect_object(1, 0, 42)
      pdf = render(File.build(%File{version: "2.0", body: [obj], root_object: {1, 0}, id: @fixed_id}))
      assert String.ends_with?(pdf, "%%EOF\n")
    end

    test "xref free entry is 0000000000 65535 f and exactly 20 bytes" do
      obj = Objects.indirect_object(1, 0, 42)
      pdf = render(File.build(%File{version: "2.0", body: [obj], root_object: {1, 0}, id: @fixed_id}))
      [free | _] = extract_xref_entries(pdf)
      assert byte_size(free) == 20
      assert free == "0000000000 65535 f \n"
    end

    test "xref in-use entries are exactly 20 bytes each" do
      obj = Objects.indirect_object(1, 0, 42)
      pdf = render(File.build(%File{version: "2.0", body: [obj], root_object: {1, 0}, id: @fixed_id}))
      [_free | entries] = extract_xref_entries(pdf)

      for entry <- entries do
        assert byte_size(entry) == 20
      end
    end

    test "startxref offset matches actual position of xref table" do
      obj = Objects.indirect_object(1, 0, 42)
      pdf = render(File.build(%File{version: "2.0", body: [obj], root_object: {1, 0}, id: @fixed_id}))
      {xref_pos, _} = :binary.match(pdf, "xref\n")
      assert find_startxref_offset(pdf) == xref_pos
    end

    test "offset in xref points to the start of the object" do
      obj = Objects.indirect_object(1, 0, 42)
      pdf = render(File.build(%File{version: "2.0", body: [obj], root_object: {1, 0}, id: @fixed_id}))
      [_free, entry1] = extract_xref_entries(pdf)
      offset = entry1 |> binary_part(0, 10) |> String.to_integer()
      assert binary_part(pdf, offset, 6) == "1 0 ob"
    end

    test "object offsets for multiple objects each point to their start" do
      obj1 = Objects.indirect_object(1, 0, 42)
      obj2 = Objects.indirect_object(2, 0, 99)
      pdf = render(File.build(%File{version: "2.0", body: [obj1, obj2], root_object: {1, 0}, id: @fixed_id}))
      [_free, entry1, entry2] = extract_xref_entries(pdf)
      off1 = entry1 |> binary_part(0, 10) |> String.to_integer()
      off2 = entry2 |> binary_part(0, 10) |> String.to_integer()
      assert binary_part(pdf, off1, 6) == "1 0 ob"
      assert binary_part(pdf, off2, 6) == "2 0 ob"
    end

    test "trailer contains /Size equal to object count + 1" do
      obj = Objects.indirect_object(1, 0, 42)
      pdf = render(File.build(%File{version: "2.0", body: [obj], root_object: {1, 0}, id: @fixed_id}))
      assert pdf =~ "/Size 2"
    end

    test "trailer contains /Root pointing to root object" do
      obj = Objects.indirect_object(1, 0, 42)
      pdf = render(File.build(%File{version: "2.0", body: [obj], root_object: {1, 0}, id: @fixed_id}))
      assert pdf =~ "/Root 1 0 R"
    end

    test "trailer contains /ID as two hex strings" do
      {id1, id2} = @fixed_id
      obj = Objects.indirect_object(1, 0, 42)
      pdf = render(File.build(%File{version: "2.0", body: [obj], root_object: {1, 0}, id: @fixed_id}))
      h1 = Base.encode16(id1)
      h2 = Base.encode16(id2)
      assert pdf =~ "/ID [<#{h1}> <#{h2}>]"
    end
  end
end
