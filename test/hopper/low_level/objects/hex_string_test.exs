defmodule Hoper.LowLevel.Objects.HexStringTest do
  use ExUnit.Case, async: true

  alias Hoper.LowLevel.Objects
  alias Hoper.LowLevel.Objects.HexString

  describe "hex_string/1" do
    test "encodes bytes as uppercase hex digits wrapped in angle brackets" do
      assert IO.iodata_to_binary(HexString.to_iodata(Objects.hex_string("Nop"))) == "<4E6F70>"
    end

    test "empty string" do
      assert IO.iodata_to_binary(HexString.to_iodata(Objects.hex_string(""))) == "<>"
    end

    test "single byte" do
      assert IO.iodata_to_binary(HexString.to_iodata(Objects.hex_string(<<0xFF>>))) == "<FF>"
    end

    test "binary data" do
      assert IO.iodata_to_binary(HexString.to_iodata(Objects.hex_string(<<0x90, 0x1F, 0xA3>>))) == "<901FA3>"
    end
  end
end
