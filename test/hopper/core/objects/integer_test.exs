defmodule Hoper.Core.Objects.IntegerTest do
  use ExUnit.Case, async: true

  alias Hoper.Core.Objects
  alias Hoper.Core.Objects.Integer

  describe "integer/1" do
    test "positive integer" do
      assert IO.iodata_to_binary(Integer.to_iodata(Objects.integer(123))) == "123"
    end

    test "negative integer" do
      assert IO.iodata_to_binary(Integer.to_iodata(Objects.integer(-98))) == "-98"
    end

    test "zero" do
      assert IO.iodata_to_binary(Integer.to_iodata(Objects.integer(0))) == "0"
    end

    test "large integer" do
      assert IO.iodata_to_binary(Integer.to_iodata(Objects.integer(43445))) == "43445"
    end
  end
end
