defmodule HopperKinoTest do
  use ExUnit.Case

  alias Hopper.Core.{File, Objects}

  describe "HopperKino.new/1" do
    test "wraps Hopper.Core.File in a Kino.JS widget" do
      catalog =
        Objects.dictionary([
          {"Type", Objects.name("Catalog")},
          {"Pages", Objects.indirect_reference(2, 0)}
        ])

      pages =
        Objects.dictionary([
          {"Type", Objects.name("Pages")},
          {"Kids", [Objects.indirect_reference(3, 0)]},
          {"Count", 1}
        ])

      page =
        Objects.dictionary([
          {"Type", Objects.name("Page")},
          {"Parent", Objects.indirect_reference(2, 0)},
          {"MediaBox", [0, 0, 612, 792]}
        ])

      file = %File{
        body: [
          Objects.indirect_object(1, 0, catalog),
          Objects.indirect_object(2, 0, pages),
          Objects.indirect_object(3, 0, page)
        ],
        root_object: {1, 0},
        id: {:crypto.strong_rand_bytes(16), :crypto.strong_rand_bytes(16)}
      }

      widget = HopperKino.new(file)
      assert %Kino.JS{module: HopperKino.PDF} = widget
    end
  end

  describe "HopperKino.PDF.new/1" do
    test "wraps PDF binary in a Kino.JS widget" do
      widget = HopperKino.PDF.new(<<37, 80, 68, 70, 45, 50, 46, 48>>)
      assert %Kino.JS{module: HopperKino.PDF} = widget
    end
  end
end
