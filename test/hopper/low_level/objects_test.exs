defmodule Hoper.LowLevel.ObjectsTest do
  use ExUnit.Case, async: true

  alias Hoper.LowLevel.Objects

  describe "lit_string/1" do
    test "wraps string in parentheses" do
      assert IO.iodata_to_binary(Objects.lit_string("hello")) == "(hello)"
    end

    test "empty string" do
      assert IO.iodata_to_binary(Objects.lit_string("")) == "()"
    end

    test "escapes backslash" do
      assert IO.iodata_to_binary(Objects.lit_string("a\\b")) == "(a\\\\b)"
    end

    test "escapes left parenthesis" do
      assert IO.iodata_to_binary(Objects.lit_string("a(b")) == "(a\\(b)"
    end

    test "escapes right parenthesis" do
      assert IO.iodata_to_binary(Objects.lit_string("a)b")) == "(a\\)b)"
    end

    test "escapes newline" do
      assert IO.iodata_to_binary(Objects.lit_string("a\nb")) == "(a\\nb)"
    end

    test "escapes carriage return" do
      assert IO.iodata_to_binary(Objects.lit_string("a\rb")) == "(a\\rb)"
    end

    test "escapes horizontal tab" do
      assert IO.iodata_to_binary(Objects.lit_string("a\tb")) == "(a\\tb)"
    end

    test "escapes backspace" do
      assert IO.iodata_to_binary(Objects.lit_string("a\bb")) == "(a\\bb)"
    end

    test "escapes form feed" do
      assert IO.iodata_to_binary(Objects.lit_string("a\fb")) == "(a\\fb)"
    end
  end

  describe "hex_string/1" do
    test "encodes bytes as uppercase hex digits wrapped in angle brackets" do
      assert IO.iodata_to_binary(Objects.hex_string("Nop")) == "<4E6F70>"
    end

    test "empty string" do
      assert IO.iodata_to_binary(Objects.hex_string("")) == "<>"
    end

    test "single byte" do
      assert IO.iodata_to_binary(Objects.hex_string(<<0xFF>>)) == "<FF>"
    end

    test "binary data" do
      assert IO.iodata_to_binary(Objects.hex_string(<<0x90, 0x1F, 0xA3>>)) == "<901FA3>"
    end
  end
end
