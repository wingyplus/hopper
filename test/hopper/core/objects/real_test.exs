defmodule Hoper.Core.Objects.RealTest do
  use ExUnit.Case, async: true

  alias Hoper.Core.Object

  describe "float" do
    test "positive real" do
      assert IO.iodata_to_binary(Object.to_iodata(34.5)) == "34.5"
    end

    test "negative real" do
      assert IO.iodata_to_binary(Object.to_iodata(-3.62)) == "-3.62"
    end

    test "positive with sign" do
      assert IO.iodata_to_binary(Object.to_iodata(123.6)) == "123.6"
    end

    test "trailing decimal point" do
      assert IO.iodata_to_binary(Object.to_iodata(4.0)) == "4.0"
    end

    test "leading decimal point" do
      assert IO.iodata_to_binary(Object.to_iodata(-0.002)) == "-0.002"
    end

    test "zero" do
      assert IO.iodata_to_binary(Object.to_iodata(0.0)) == "0.0"
    end
  end
end
