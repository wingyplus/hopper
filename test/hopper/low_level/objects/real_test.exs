defmodule Hoper.LowLevel.Objects.RealTest do
  use ExUnit.Case, async: true

  alias Hoper.LowLevel.Objects
  alias Hoper.LowLevel.Objects.Real

  describe "real/1" do
    test "positive real" do
      assert IO.iodata_to_binary(Real.to_iodata(Objects.real(34.5))) == "34.5"
    end

    test "negative real" do
      assert IO.iodata_to_binary(Real.to_iodata(Objects.real(-3.62))) == "-3.62"
    end

    test "positive with sign" do
      assert IO.iodata_to_binary(Real.to_iodata(Objects.real(123.6))) == "123.6"
    end

    test "trailing decimal point" do
      assert IO.iodata_to_binary(Real.to_iodata(Objects.real(4.0))) == "4.0"
    end

    test "leading decimal point" do
      assert IO.iodata_to_binary(Real.to_iodata(Objects.real(-0.002))) == "-0.002"
    end

    test "zero" do
      assert IO.iodata_to_binary(Real.to_iodata(Objects.real(0.0))) == "0.0"
    end
  end
end
