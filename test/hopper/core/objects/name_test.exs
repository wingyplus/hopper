defmodule Hopper.Core.Objects.NameTest do
  use ExUnit.Case, async: true

  import Hopper.ObjectHelpers
  alias Hopper.Core.Objects

  describe "name/1" do
    test "simple name" do
      assert render(Objects.name("Name1")) == "/Name1"
    end

    test "longer name" do
      assert render(Objects.name("ASomewhatLongerName")) == "/ASomewhatLongerName"
    end

    test "encodes space as hex" do
      assert render(Objects.name("Lime Green")) == "/Lime#20Green"
    end

    test "encodes parentheses as hex" do
      assert render(Objects.name("paired()parentheses")) == "/paired#28#29parentheses"
    end

    test "encodes number sign as hex" do
      assert render(Objects.name("The_Key_of_F#_Minor")) == "/The_Key_of_F#23_Minor"
    end

    test "empty name" do
      assert render(Objects.name("")) == "/"
    end

    test "encodes slash as hex" do
      assert render(Objects.name("A/B")) == "/A#2FB"
    end

    test "encodes null byte as hex" do
      assert render(Objects.name("A\x00B")) == "/A#00B"
    end
  end
end
