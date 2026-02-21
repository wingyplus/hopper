defmodule Hoper.Core.Objects.ArrayTest do
  use ExUnit.Case, async: true

  import Hoper.ObjectHelpers
  alias Hoper.Core.Objects

  describe "array/1" do
    test "empty array" do
      assert render(Objects.array([])) == "[]"
    end

    test "array with single element" do
      assert render(Objects.array([Objects.name("Type")])) == "[/Type]"
    end

    test "array with multiple elements" do
      assert render(
               Objects.array([
                 Objects.lit_string("hello"),
                 Objects.name("World")
               ])
             ) == "[(hello) /World]"
    end

    test "nested array" do
      assert render(
               Objects.array([
                 Objects.array([Objects.name("A")]),
                 Objects.name("B")
               ])
             ) == "[[/A] /B]"
    end
  end
end
