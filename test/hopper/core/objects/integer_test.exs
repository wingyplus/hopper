defmodule Hopper.Core.Objects.IntegerTest do
  use ExUnit.Case, async: true

  import Hopper.ObjectHelpers

  describe "integer" do
    test "positive integer" do
      assert render(123) == "123"
    end

    test "negative integer" do
      assert render(-98) == "-98"
    end

    test "zero" do
      assert render(0) == "0"
    end

    test "large integer" do
      assert render(43445) == "43445"
    end
  end
end
