defmodule Hopper.Core.DocumentTest do
  use ExUnit.Case, async: true

  import Hopper.ObjectHelpers
  alias Hopper.Core.Objects
  alias Hopper.Core.Document

  # ---------------------------------------------------------------------------
  # catalog/2
  # ---------------------------------------------------------------------------

  describe "catalog/2" do
    test "required keys only — produces /Type /Catalog and /Pages" do
      pages_ref = Objects.indirect_reference(2)
      result = render(Document.catalog(pages_ref))
      assert result == "<< /Type /Catalog /Pages 2 0 R >>"
    end

    test "raises when pages_ref is not an IndirectReference" do
      assert_raise FunctionClauseError, fn ->
        Document.catalog(Objects.dictionary([]))
      end
    end

    test "raises when pages_ref is a plain integer" do
      assert_raise FunctionClauseError, fn ->
        Document.catalog(2)
      end
    end

    test "optional :version key is included when supplied" do
      pages_ref = Objects.indirect_reference(2)
      result = render(Document.catalog(pages_ref, version: Objects.name("2.0")))
      assert result =~ "/Version /2.0"
    end

    test "optional :page_layout key is included when supplied" do
      pages_ref = Objects.indirect_reference(2)
      result = render(Document.catalog(pages_ref, page_layout: Objects.name("SinglePage")))
      assert result =~ "/PageLayout /SinglePage"
    end

    test "optional :page_mode key is included when supplied" do
      pages_ref = Objects.indirect_reference(2)
      result = render(Document.catalog(pages_ref, page_mode: Objects.name("UseNone")))
      assert result =~ "/PageMode /UseNone"
    end

    test "optional :lang key is included when supplied" do
      pages_ref = Objects.indirect_reference(2)
      result = render(Document.catalog(pages_ref, lang: Objects.lit_string("en-US")))
      assert result =~ "/Lang (en-US)"
    end

    test "optional :metadata key must be an IndirectReference and is included" do
      pages_ref = Objects.indirect_reference(2)
      meta_ref = Objects.indirect_reference(6)
      result = render(Document.catalog(pages_ref, metadata: meta_ref))
      assert result =~ "/Metadata 6 0 R"
    end

    test "optional :names key is included when supplied" do
      pages_ref = Objects.indirect_reference(2)
      names_dict = Objects.dictionary([{"EmbeddedFiles", Objects.indirect_reference(7)}])
      result = render(Document.catalog(pages_ref, names: names_dict))
      assert result =~ "/Names"
    end

    test "all optional keys together produce the correct dictionary" do
      pages_ref = Objects.indirect_reference(2)
      meta_ref = Objects.indirect_reference(6)

      result =
        render(
          Document.catalog(pages_ref,
            version: Objects.name("2.0"),
            metadata: meta_ref
          )
        )

      assert result =~ "/Type /Catalog"
      assert result =~ "/Pages 2 0 R"
      assert result =~ "/Version /2.0"
      assert result =~ "/Metadata 6 0 R"
    end

    test "omitted optional keys do not appear in output" do
      pages_ref = Objects.indirect_reference(2)
      result = render(Document.catalog(pages_ref))
      refute result =~ "/Version"
      refute result =~ "/PageLayout"
      refute result =~ "/PageMode"
      refute result =~ "/Lang"
      refute result =~ "/Metadata"
      refute result =~ "/Names"
    end
  end

  # ---------------------------------------------------------------------------
  # page_tree/3
  # ---------------------------------------------------------------------------

  describe "page_tree/3" do
    test "required keys only — /Type /Pages, /Kids, and /Count" do
      kid_ref = Objects.indirect_reference(3)
      result = render(Document.page_tree([kid_ref], 1))
      assert result == "<< /Type /Pages /Kids [3 0 R] /Count 1 >>"
    end

    test "multiple kids are included in order" do
      kid1 = Objects.indirect_reference(3)
      kid2 = Objects.indirect_reference(4)
      result = render(Document.page_tree([kid1, kid2], 2))
      assert result =~ "[3 0 R 4 0 R]"
      assert result =~ "/Count 2"
    end

    test "empty kids list produces an empty array" do
      result = render(Document.page_tree([], 0))
      assert result =~ "/Kids []"
      assert result =~ "/Count 0"
    end

    test "optional :parent ref is included when supplied" do
      parent_ref = Objects.indirect_reference(1)
      kid_ref = Objects.indirect_reference(3)
      result = render(Document.page_tree([kid_ref], 1, parent: parent_ref))
      assert result =~ "/Parent 1 0 R"
    end

    test "omitted :parent does not appear in output" do
      kid_ref = Objects.indirect_reference(3)
      result = render(Document.page_tree([kid_ref], 1))
      refute result =~ "/Parent"
    end
  end

  # ---------------------------------------------------------------------------
  # page/3
  # ---------------------------------------------------------------------------

  describe "page/3" do
    test "required keys only — /Type /Page, /Parent, /MediaBox, /Resources" do
      parent_ref = Objects.indirect_reference(2)
      result = render(Document.page(parent_ref, [0, 0, 612, 792]))

      assert result =~ "/Type /Page"
      assert result =~ "/Parent 2 0 R"
      assert result =~ "/MediaBox [0 0 612 792]"
      assert result =~ "/Resources <<>>"
    end

    test "default /Resources is an empty dictionary" do
      parent_ref = Objects.indirect_reference(2)
      result = render(Document.page(parent_ref, [0, 0, 612, 792]))
      assert result =~ "/Resources <<>>"
    end

    test "raises when parent_ref is not an IndirectReference" do
      assert_raise FunctionClauseError, fn ->
        Document.page(42, [0, 0, 612, 792])
      end
    end

    test "optional :resources dictionary is included when supplied" do
      parent_ref = Objects.indirect_reference(2)
      font_ref = Objects.indirect_reference(5)
      font_dict = Objects.dictionary([{"F1", font_ref}])
      resources = Objects.dictionary([{"Font", font_dict}])

      result = render(Document.page(parent_ref, [0, 0, 612, 792], resources: resources))
      assert result =~ "/Font"
    end

    test "optional :contents reference is included when supplied" do
      parent_ref = Objects.indirect_reference(2)
      contents_ref = Objects.indirect_reference(4)
      result = render(Document.page(parent_ref, [0, 0, 612, 792], contents: contents_ref))
      assert result =~ "/Contents 4 0 R"
    end

    test "optional :rotate value is included when supplied" do
      parent_ref = Objects.indirect_reference(2)
      result = render(Document.page(parent_ref, [0, 0, 612, 792], rotate: 90))
      assert result =~ "/Rotate 90"
    end

    test "optional :crop_box is included when supplied" do
      parent_ref = Objects.indirect_reference(2)
      result = render(Document.page(parent_ref, [0, 0, 612, 792], crop_box: [18, 18, 594, 774]))
      assert result =~ "/CropBox [18 18 594 774]"
    end

    test "omitted optional keys do not appear in output" do
      parent_ref = Objects.indirect_reference(2)
      result = render(Document.page(parent_ref, [0, 0, 612, 792]))
      refute result =~ "/Contents"
      refute result =~ "/Rotate"
      refute result =~ "/CropBox"
    end

    test "page with all optional keys" do
      parent_ref = Objects.indirect_reference(2)
      contents_ref = Objects.indirect_reference(4)
      resources = Objects.dictionary([{"Font", Objects.dictionary([])}])

      result =
        render(
          Document.page(parent_ref, [0, 0, 612, 792],
            resources: resources,
            contents: contents_ref,
            rotate: 0,
            crop_box: [0, 0, 612, 792]
          )
        )

      assert result =~ "/Type /Page"
      assert result =~ "/Parent 2 0 R"
      assert result =~ "/MediaBox [0 0 612 792]"
      assert result =~ "/Contents 4 0 R"
      assert result =~ "/Rotate 0"
      assert result =~ "/CropBox [0 0 612 792]"
    end
  end
end
