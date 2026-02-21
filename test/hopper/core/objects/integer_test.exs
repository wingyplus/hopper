defmodule Hoper.Core.Objects.IntegerTest do
  use ExUnit.Case, async: true

  alias Hoper.Core.Object

  describe "integer" do
    test "positive integer" do
      assert IO.iodata_to_binary(Object.to_iodata(123)) == "123"
    end

    test "negative integer" do
      assert IO.iodata_to_binary(Object.to_iodata(-98)) == "-98"
    end

    test "zero" do
      assert IO.iodata_to_binary(Object.to_iodata(0)) == "0"
    end

    test "large integer" do
      assert IO.iodata_to_binary(Object.to_iodata(43445)) == "43445"
    end
  end
end
