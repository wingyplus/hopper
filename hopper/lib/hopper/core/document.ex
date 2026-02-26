defmodule Hopper.Core.Document do
  @moduledoc """
  Factory functions for building PDF §7.7 Document Structure objects.

  These functions produce properly structured `%Dictionary{}` values
  that conform to the PDF 2.0 (ISO 32000-2) document structure requirements
  for the Catalog, Page Tree, and Page Object dictionaries.

  All returned values are `%Dictionary{}` structs. Callers are responsible
  for wrapping them in `%IndirectObject{}` (via `Objects.indirect_object/3`)
  and assembling the final file via `Hopper.Core.File.build/1`.
  """

  alias Hopper.Core.Objects
  alias Hopper.Core.Objects.IndirectReference

  @doc """
  Builds a Catalog dictionary (§7.7.2).

  The `/Type` key is always set to `/Catalog`. The `pages_ref` argument
  must be an `%IndirectReference{}` pointing to the root Page Tree node.

  ## Options

    * `:metadata` — an `%IndirectReference{}` for the document metadata stream
    * `:version` — a `%Name{}` giving the PDF version (e.g. `Objects.name("2.0")`)
    * `:page_layout` — a `%Name{}` specifying the page layout
    * `:page_mode` — a `%Name{}` specifying the page mode
    * `:lang` — a `%LitString{}` or binary specifying the document language
    * `:names` — a `%Dictionary{}` for the Names dictionary (§7.7.4)

  ## Examples

      iex> alias Hopper.Core.Objects
      iex> pages_ref = Objects.indirect_reference(2)
      iex> catalog = Hopper.Core.Document.catalog(pages_ref)
      iex> is_struct(catalog, Hopper.Core.Objects.Dictionary)
      true

  """
  @spec catalog(IndirectReference.t(), keyword()) :: Hopper.Core.Objects.Dictionary.t()
  def catalog(%IndirectReference{} = pages_ref, opts \\ []) do
    required = [
      {"Type", Objects.name("Catalog")},
      {"Pages", pages_ref}
    ]

    optional =
      []
      |> maybe_put("Version", Keyword.get(opts, :version))
      |> maybe_put("PageLayout", Keyword.get(opts, :page_layout))
      |> maybe_put("PageMode", Keyword.get(opts, :page_mode))
      |> maybe_put("Lang", Keyword.get(opts, :lang))
      |> maybe_put("Metadata", Keyword.get(opts, :metadata))
      |> maybe_put("Names", Keyword.get(opts, :names))

    Objects.dictionary(required ++ optional)
  end

  @doc """
  Builds a Page Tree node dictionary (§7.7.3.2).

  The `/Type` key is always set to `/Pages`. `kids` must be a list of
  `%IndirectReference{}` values pointing to child nodes or page objects.
  `count` is the total number of leaf Page objects in the entire subtree
  rooted at this node.

  ## Options

    * `:parent` — an `%IndirectReference{}` to the parent Pages node
      (required for all non-root nodes)

  ## Examples

      iex> alias Hopper.Core.Objects
      iex> kid_ref = Objects.indirect_reference(3)
      iex> tree = Hopper.Core.Document.page_tree([kid_ref], 1)
      iex> is_struct(tree, Hopper.Core.Objects.Dictionary)
      true

  """
  @spec page_tree([IndirectReference.t()], non_neg_integer(), keyword()) ::
          Hopper.Core.Objects.Dictionary.t()
  def page_tree(kids, count, opts \\ [])
      when is_list(kids) and is_integer(count) and count >= 0 do
    required = [
      {"Type", Objects.name("Pages")},
      {"Kids", kids},
      {"Count", count}
    ]

    optional =
      []
      |> maybe_put("Parent", Keyword.get(opts, :parent))

    Objects.dictionary(required ++ optional)
  end

  @doc """
  Builds a Page object dictionary (§7.7.3.3).

  The `/Type` key is always set to `/Page`. `parent_ref` must be an
  `%IndirectReference{}` pointing to the parent Pages node.
  `media_box` is a four-element list `[llx, lly, urx, ury]` defining the
  page boundaries.

  `/Resources` defaults to an empty dictionary (`<<>>`) if not supplied.

  ## Options

    * `:resources` — a `%Dictionary{}` for page resources (fonts, images, etc.)
    * `:contents` — an `%IndirectReference{}` or list of `%IndirectReference{}`
      for the page content stream(s); omit if the page has no content
    * `:rotate` — an integer multiple of 90 for page rotation (default 0)
    * `:crop_box` — a four-element list `[llx, lly, urx, ury]`

  ## Examples

      iex> alias Hopper.Core.Objects
      iex> parent_ref = Objects.indirect_reference(2)
      iex> page = Hopper.Core.Document.page(parent_ref, [0, 0, 612, 792])
      iex> is_struct(page, Hopper.Core.Objects.Dictionary)
      true

  """
  @spec page(IndirectReference.t(), [number()], keyword()) :: Hopper.Core.Objects.Dictionary.t()
  def page(%IndirectReference{} = parent_ref, [llx, lly, urx, ury] = _media_box, opts \\ []) do
    resources = Keyword.get(opts, :resources, Objects.dictionary([]))

    required = [
      {"Type", Objects.name("Page")},
      {"Parent", parent_ref},
      {"MediaBox", [llx, lly, urx, ury]},
      {"Resources", resources}
    ]

    optional =
      []
      |> maybe_put("Contents", Keyword.get(opts, :contents))
      |> maybe_put("Rotate", Keyword.get(opts, :rotate))
      |> maybe_put("CropBox", Keyword.get(opts, :crop_box))

    Objects.dictionary(required ++ optional)
  end

  # Adds `{key, value}` to `acc` only when `value` is not nil.
  defp maybe_put(acc, _key, nil), do: acc
  defp maybe_put(acc, key, value), do: acc ++ [{key, value}]
end
