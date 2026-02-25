defmodule Hopper.Core.Objects.RealTest do
  use ExUnit.Case, async: true

  import Hopper.ObjectHelpers

  describe "float" do
    test "positive real" do
      assert render(34.5) == "34.5"
    end

    test "negative real" do
      assert render(-3.62) == "-3.62"
    end

    test "positive with sign" do
      assert render(123.6) == "123.6"
    end

    test "trailing decimal point" do
      assert render(4.0) == "4.0"
    end

    test "leading decimal point" do
      assert render(-0.002) == "-0.002"
    end

    test "zero" do
      assert render(0.0) == "0.0"
    end
  end
end
