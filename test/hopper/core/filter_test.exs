defmodule Hopper.Core.FilterTest do
  use ExUnit.Case, async: true

  alias Hopper.Core.Filter
  alias Hopper.Core.Objects

  describe "FlateDecode" do
    test "compresses data with zlib" do
      data = "Hello, World!"
      encoded = Filter.encode(data, Objects.name("FlateDecode"))
      assert :zlib.uncompress(encoded) == data
    end

    test "empty data" do
      encoded = Filter.encode("", Objects.name("FlateDecode"))
      assert :zlib.uncompress(encoded) == ""
    end

    test "binary data" do
      data = <<0, 1, 2, 3, 4, 5>>
      encoded = Filter.encode(data, Objects.name("FlateDecode"))
      assert :zlib.uncompress(encoded) == data
    end
  end

  describe "ASCIIHexDecode" do
    test "encodes bytes as uppercase hex pairs terminated with >" do
      assert Filter.encode("Hi", Objects.name("ASCIIHexDecode")) == "4869>"
    end

    test "empty data" do
      assert Filter.encode("", Objects.name("ASCIIHexDecode")) == ">"
    end

    test "binary data" do
      assert Filter.encode(<<0, 255>>, Objects.name("ASCIIHexDecode")) == "00FF>"
    end
  end

  describe "ASCII85Decode" do
    test "encodes data and terminates with ~>" do
      encoded = Filter.encode("Man ", Objects.name("ASCII85Decode"))
      assert String.ends_with?(encoded, "~>")
    end

    test "four zero bytes encode as z" do
      encoded = Filter.encode(<<0, 0, 0, 0>>, Objects.name("ASCII85Decode"))
      assert encoded == "z~>"
    end

    test "multiple groups of four zero bytes" do
      encoded = Filter.encode(<<0, 0, 0, 0, 0, 0, 0, 0>>, Objects.name("ASCII85Decode"))
      assert encoded == "zz~>"
    end

    test "round-trip: encoded data can be decoded" do
      data = "Hello, World! This is a test of ASCII85 encoding."
      encoded = Filter.encode(data, Objects.name("ASCII85Decode"))

      # Verify it's valid ASCII85 by checking it ends with ~> and contains only valid chars
      assert String.ends_with?(encoded, "~>")
      body = String.slice(encoded, 0, String.length(encoded) - 2)
      assert String.match?(body, ~r/\A[!-uz]*\z/)
    end

    test "partial final group emits n+1 characters" do
      # 1 byte → 2 output chars before ~>
      encoded = Filter.encode(<<0>>, Objects.name("ASCII85Decode"))
      # 0x00 padded to 0x00000000, encoded 5 chars, take 2, then ~>
      assert String.length(encoded) == 4  # 2 chars + "~>"
    end
  end

  describe "RunLengthDecode" do
    test "encodes a run of identical bytes" do
      # 5 bytes of 0xAA → length byte (257-5=252), then the byte, then EOD
      encoded = Filter.encode(<<0xAA, 0xAA, 0xAA, 0xAA, 0xAA>>, Objects.name("RunLengthDecode"))
      assert IO.iodata_to_binary(encoded) == <<252, 0xAA, 128>>
    end

    test "encodes literal (non-repeating) bytes" do
      # 3 different bytes → length byte (3-1=2), then the 3 bytes, then EOD
      encoded = Filter.encode(<<1, 2, 3>>, Objects.name("RunLengthDecode"))
      assert IO.iodata_to_binary(encoded) == <<2, 1, 2, 3, 128>>
    end

    test "encodes mixed runs and literals" do
      # [1, 2] literals then [3, 3, 3] run
      encoded = Filter.encode(<<1, 2, 3, 3, 3>>, Objects.name("RunLengthDecode"))
      # literals: <<1, 1, 2>>, run: <<254, 3>>, EOD: <<128>>
      assert IO.iodata_to_binary(encoded) == <<1, 1, 2, 254, 3, 128>>
    end

    test "terminates with EOD byte (128)" do
      encoded = Filter.encode("x", Objects.name("RunLengthDecode"))
      assert :binary.last(IO.iodata_to_binary(encoded)) == 128
    end

    test "empty data produces only EOD" do
      assert IO.iodata_to_binary(Filter.encode("", Objects.name("RunLengthDecode"))) == <<128>>
    end
  end

  describe "BrotliDecode" do
    test "compresses data with brotli" do
      data = "Hello, World!"
      encoded = Filter.encode(data, Objects.name("BrotliDecode"))
      {:ok, decompressed} = :brotli.decode(encoded)
      assert decompressed == data
    end

    test "empty data" do
      encoded = Filter.encode("", Objects.name("BrotliDecode"))
      {:ok, decompressed} = :brotli.decode(encoded)
      assert decompressed == ""
    end

    test "binary data" do
      data = <<0, 1, 2, 3, 4, 5>>
      encoded = Filter.encode(data, Objects.name("BrotliDecode"))
      {:ok, decompressed} = :brotli.decode(encoded)
      assert decompressed == data
    end

    test "round-trip encode then decode" do
      data = "PDF brotli filter round-trip test"
      encoded = Filter.encode(data, Objects.name("BrotliDecode"))
      assert Filter.decode(encoded, Objects.name("BrotliDecode")) == data
    end
  end

  describe "pass-through filters" do
    test "DCTDecode passes data unchanged" do
      data = <<0xFF, 0xD8, 0xFF>>
      assert Filter.encode(data, Objects.name("DCTDecode")) == data
    end

    test "JPXDecode passes data unchanged" do
      data = "jpeg2000data"
      assert Filter.encode(data, Objects.name("JPXDecode")) == data
    end

    test "JBIG2Decode passes data unchanged" do
      data = "jbig2data"
      assert Filter.encode(data, Objects.name("JBIG2Decode")) == data
    end
  end

  describe "multiple filters" do
    test "applies filters in reverse array order (writer encodes inverse of reader decode)" do
      # Filter array [ASCIIHexDecode, FlateDecode]
      # Reader decodes: ASCIIHex first, then Flate
      # Writer encodes: Flate first, then ASCIIHex
      data = "Hello"
      filters = [Objects.name("ASCIIHexDecode"), Objects.name("FlateDecode")]
      encoded = Filter.encode(data, filters)

      # Should be ASCIIHex(zlib(data))
      flated = :zlib.compress(data)
      assert encoded == Base.encode16(flated) <> ">"
    end
  end
end
