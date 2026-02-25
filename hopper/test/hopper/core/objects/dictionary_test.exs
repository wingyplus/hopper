defmodule Hopper.Core.Objects.DictionaryTest do
  use ExUnit.Case, async: true

  import Hopper.ObjectHelpers
  alias Hopper.Core.Objects

  describe "dictionary/1" do
    test "empty dictionary" do
      assert render(Objects.dictionary([])) == "<<>>"
    end

    test "empty map" do
      assert render(Objects.dictionary(%{})) == "<<>>"
    end

    test "map with single entry" do
      assert render(Objects.dictionary(%{"Type" => Objects.name("Font")})) ==
               "<< /Type /Font >>"
    end

    test "single name value" do
      assert render(Objects.dictionary([{"Type", Objects.name("Font")}])) ==
               "<< /Type /Font >>"
    end

    test "multiple entries" do
      assert render(
               Objects.dictionary([
                 {"Type", Objects.name("Font")},
                 {"Subtype", Objects.name("Type1")}
               ])
             ) == "<< /Type /Font /Subtype /Type1 >>"
    end

    test "integer value" do
      assert render(Objects.dictionary([{"IntegerItem", 12}])) ==
               "<< /IntegerItem 12 >>"
    end

    test "real value" do
      assert render(Objects.dictionary([{"Version", 0.01}])) ==
               "<< /Version 0.01 >>"
    end

    test "boolean value" do
      assert render(Objects.dictionary([{"Flag", Objects.boolean(true)}])) ==
               "<< /Flag true >>"
    end

    test "literal string value" do
      assert render(Objects.dictionary([{"StringItem", Objects.lit_string("a string")}])) ==
               "<< /StringItem (a string) >>"
    end

    test "hex string value" do
      assert render(Objects.dictionary([{"ID", Objects.hex_string(<<0x90, 0x1F>>)}])) ==
               "<< /ID <901F> >>"
    end

    test "array value" do
      assert render(
               Objects.dictionary([
                 {"Kids", [Objects.name("A"), Objects.name("B")]}
               ])
             ) == "<< /Kids [/A /B] >>"
    end

    test "nested dictionary" do
      inner = Objects.dictionary([{"Item1", 0.4}, {"Item2", Objects.boolean(true)}])

      assert render(Objects.dictionary([{"Subdictionary", inner}])) ==
               "<< /Subdictionary << /Item1 0.4 /Item2 true >> >>"
    end

    test "key with special characters is encoded" do
      assert render(Objects.dictionary([{"Key With Space", Objects.boolean(true)}])) ==
               "<< /Key#20With#20Space true >>"
    end
  end
end
