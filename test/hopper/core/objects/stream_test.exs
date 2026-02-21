defmodule Hoper.Core.Objects.StreamTest do
  use ExUnit.Case, async: true

  import Hoper.ObjectHelpers
  alias Hoper.Core.Objects

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

    test "stream with Filter entry" do
      assert render(Objects.stream([{"Filter", Objects.name("FlateDecode")}], "data")) ==
               "<< /Length 4 /Filter /FlateDecode >>\nstream\ndata\nendstream"
    end

    test "stream with multiple dictionary entries" do
      assert render(
               Objects.stream(
                 [{"Filter", Objects.name("FlateDecode")}, {"DL", 100}],
                 "data"
               )
             ) == "<< /Length 4 /Filter /FlateDecode /DL 100 >>\nstream\ndata\nendstream"
    end

    test "stream with binary data" do
      data = <<0, 1, 2, 3>>

      assert render(Objects.stream([], data)) ==
               "<< /Length 4 >>\nstream\n" <> data <> "\nendstream"
    end
  end
end
