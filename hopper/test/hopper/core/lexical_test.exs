defmodule Hopper.Core.LexicalTest do
  use ExUnit.Case, async: true

  alias Hopper.Core.Lexical

  defp render(iodata), do: IO.iodata_to_binary(iodata)

  describe "comment/1" do
    test "prefixes text with percent sign" do
      assert String.starts_with?(render(Lexical.comment("Hello")), "%")
    end

    test "includes the comment body text" do
      assert render(Lexical.comment("Hello")) =~ "Hello"
    end

    test "produces valid comment for a typical body" do
      assert render(Lexical.comment("Hello")) == "%Hello"
    end

    test "produces valid comment for an empty body" do
      assert render(Lexical.comment("")) == "%"
    end

    test "produces valid comment for body containing special characters" do
      assert render(Lexical.comment("PDF-2.0")) == "%PDF-2.0"
    end

    test "returns iodata (list)" do
      assert is_list(Lexical.comment("test"))
    end
  end
end
