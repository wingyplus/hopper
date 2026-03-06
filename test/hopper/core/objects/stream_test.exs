defmodule Hopper.Core.Objects.StreamTest do
  use ExUnit.Case, async: true

  import Hopper.ObjectHelpers
  alias Hopper.Core.Objects

  describe "stream/2" do
    test "empty data" do
      assert render(Objects.stream([], "")) == "<< /Length 0 >>\nstream\n\nendstream"
    end

    test "stream with data" do
      assert render(Objects.stream([], "Hello")) == "<< /Length 5 >>\nstream\nHello\nendstream"
    end

    test "length is computed from byte size of data" do
      data = "abc"
      assert render(Objects.stream([], data)) == "<< /Length 3 >>\nstream\nabc\nendstream"
    end

    test "stream with FlateDecode filter compresses data" do
      raw = "data"
      compressed = :zlib.compress(raw)

      assert render(Objects.stream([{"Filter", Objects.name("FlateDecode")}], raw)) ==
               "<< /Length #{byte_size(compressed)} /Filter /FlateDecode >>\nstream\n" <>
                 compressed <> "\nendstream"
    end

    test "stream with multiple dictionary entries encodes data" do
      raw = "data"
      compressed = :zlib.compress(raw)

      assert render(
               Objects.stream(
                 [{"Filter", Objects.name("FlateDecode")}, {"DL", 100}],
                 raw
               )
             ) ==
               "<< /Length #{byte_size(compressed)} /Filter /FlateDecode /DL 100 >>\nstream\n" <>
                 compressed <> "\nendstream"
    end

    test "stream with binary data" do
      data = <<0, 1, 2, 3>>

      assert render(Objects.stream([], data)) ==
               "<< /Length 4 >>\nstream\n" <> data <> "\nendstream"
    end
  end
end
