defmodule Hoper.Core.Objects.ArrayTest do
  use ExUnit.Case, async: true

  alias Hoper.Core.Objects
  alias Hoper.Core.Object

  describe "array/1" do
    test "empty array" do
      assert IO.iodata_to_binary(Object.to_iodata(Objects.array([]))) == "[]"
    end

    test "array with single element" do
      assert IO.iodata_to_binary(Object.to_iodata(Objects.array([Objects.name("Type")]))) ==
               "[/Type]"
    end

    test "array with multiple elements" do
      assert IO.iodata_to_binary(
               Object.to_iodata(
                 Objects.array([
                   Objects.lit_string("hello"),
                   Objects.name("World")
                 ])
               )
             ) == "[(hello) /World]"
    end

    test "nested array" do
      assert IO.iodata_to_binary(
               Object.to_iodata(
                 Objects.array([
                   Objects.array([Objects.name("A")]),
                   Objects.name("B")
                 ])
               )
             ) == "[[/A] /B]"
    end
  end
end
