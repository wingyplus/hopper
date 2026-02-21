defmodule Hopper.Core.Objects.LitStringTest do
  use ExUnit.Case, async: true

  import Hopper.ObjectHelpers
  alias Hopper.Core.Objects

  describe "lit_string/1" do
    test "wraps string in parentheses" do
      assert render(Objects.lit_string("hello")) == "(hello)"
    end

    test "empty string" do
      assert render(Objects.lit_string("")) == "()"
    end

    test "escapes backslash" do
      assert render(Objects.lit_string("a\\b")) == "(a\\\\b)"
    end

    test "escapes left parenthesis" do
      assert render(Objects.lit_string("a(b")) == "(a\\(b)"
    end

    test "escapes right parenthesis" do
      assert render(Objects.lit_string("a)b")) == "(a\\)b)"
    end

    test "escapes newline" do
      assert render(Objects.lit_string("a\nb")) == "(a\\nb)"
    end

    test "escapes carriage return" do
      assert render(Objects.lit_string("a\rb")) == "(a\\rb)"
    end

    test "escapes horizontal tab" do
      assert render(Objects.lit_string("a\tb")) == "(a\\tb)"
    end

    test "escapes backspace" do
      assert render(Objects.lit_string("a\bb")) == "(a\\bb)"
    end

    test "escapes form feed" do
      assert render(Objects.lit_string("a\fb")) == "(a\\fb)"
    end
  end
end
