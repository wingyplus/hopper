defmodule Hopper.Core.Objects.IndirectTest do
  use ExUnit.Case, async: true

  import Hopper.ObjectHelpers
  alias Hopper.Core.Objects

  describe "indirect_object/3" do
    test "wraps a string object" do
      assert render(Objects.indirect_object(12, 0, Objects.lit_string("Brillig"))) ==
               "12 0 obj\n(Brillig)\nendobj"
    end

    test "wraps an integer object" do
      assert render(Objects.indirect_object(1, 0, 42)) ==
               "1 0 obj\n42\nendobj"
    end

    test "wraps a null object" do
      assert render(Objects.indirect_object(3, 0, nil)) ==
               "3 0 obj\nnull\nendobj"
    end

    test "generation number defaults to 0" do
      assert render(Objects.indirect_object(5, 1)) ==
               "5 0 obj\n1\nendobj"
    end

    test "non-zero generation number" do
      assert render(Objects.indirect_object(2, 1, Objects.boolean(true))) ==
               "2 1 obj\ntrue\nendobj"
    end
  end

  describe "indirect_reference/2" do
    test "renders object and generation number with R" do
      assert render(Objects.indirect_reference(12, 0)) == "12 0 R"
    end

    test "generation number defaults to 0" do
      assert render(Objects.indirect_reference(7)) == "7 0 R"
    end

    test "non-zero generation number" do
      assert render(Objects.indirect_reference(3, 2)) == "3 2 R"
    end
  end
end
