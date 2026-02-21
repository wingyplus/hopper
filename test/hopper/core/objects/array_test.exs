defmodule Hopper.Core.Objects.ArrayTest do
  use ExUnit.Case, async: true

  import Hopper.ObjectHelpers
  alias Hopper.Core.Objects

  describe "list as array" do
    test "empty array" do
      assert render([]) == "[]"
    end

    test "array with single element" do
      assert render([Objects.name("Type")]) == "[/Type]"
    end

    test "array with multiple elements" do
      assert render([
               Objects.lit_string("hello"),
               Objects.name("World")
             ]) == "[(hello) /World]"
    end

    test "nested array" do
      assert render([
               [Objects.name("A")],
               Objects.name("B")
             ]) == "[[/A] /B]"
    end
  end
end
