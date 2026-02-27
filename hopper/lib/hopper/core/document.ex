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
  Builds a Catalog dictionary (§7.7.2, Table 29).

  The `/Type` key is always set to `/Catalog`. The `pages_ref` argument
  must be an `%IndirectReference{}` pointing to the root Page Tree node.

  ## Options

    * `:version` — a `%Name{}` giving the PDF version (e.g. `Objects.name("2.0")`)
    * `:extensions` — a `%Dictionary{}` for developer extensions (§7.12)
    * `:page_labels` — a number-tree `%Dictionary{}` for page labels (§7.9.7)
    * `:names` — a `%Dictionary{}` for the Names dictionary (§7.7.4)
    * `:dests` — a `%Dictionary{}` mapping names to destinations (§12.3.2.3)
    * `:viewer_preferences` — a `%Dictionary{}` for viewer preferences (§12.2)
    * `:page_layout` — a `%Name{}` specifying the page layout (e.g. `Objects.name("SinglePage")`)
    * `:page_mode` — a `%Name{}` specifying the page mode (e.g. `Objects.name("UseNone")`)
    * `:outlines` — a `%Dictionary{}` for the document outline hierarchy (§12.3.3)
    * `:threads` — an `%Array{}` of article thread dictionaries (§12.4.3)
    * `:open_action` — a `%Dictionary{}` or `%Array{}` for the open action (§12.6.4)
    * `:aa` — a `%Dictionary{}` for document-level additional actions (§12.6.3)
    * `:uri` — a `%Dictionary{}` for document-level URI info (§12.6.4.7)
    * `:acro_form` — a `%Dictionary{}` for the interactive form (§12.7.2)
    * `:metadata` — an `%IndirectReference{}` for the document metadata stream (§14.3)
    * `:struct_tree_root` — a `%Dictionary{}` for the structure tree root (§14.7.2)
    * `:mark_info` — a `%Dictionary{}` for mark information (§14.7.1)
    * `:lang` — a `%LitString{}` or binary specifying the document language (BCP 47)
    * `:spider_info` — a `%Dictionary{}` for Web Capture information (§14.10.2)
    * `:output_intents` — an `%Array{}` of output intent dictionaries (§14.11.5)
    * `:piece_info` — a `%Dictionary{}` for document-level application data (§14.5)
    * `:oc_properties` — a `%Dictionary{}` for optional content properties (§8.11.4);
      required when the document contains optional content
    * `:perms` — a `%Dictionary{}` for access permissions (§12.8.4)
    * `:legal` — a `%Dictionary{}` for legal attestation (§12.8.5)
    * `:requirements` — an `%Array{}` of requirement dictionaries (§12.10)
    * `:collection` — a `%Dictionary{}` for PDF collection info (§12.3.5)
    * `:needs_rendering` — a boolean; deprecated in PDF 2.0
    * `:dss` — a `%Dictionary{}` for the Document Security Store (§12.8.4.3)
    * `:af` — an `%Array{}` of associated file dictionaries (§14.13)
    * `:d_part_root` — a `%Dictionary{}` for document parts hierarchy (§14.12)

  ## Examples

      iex> alias Hopper.Core.Objects
      iex> pages_ref = Objects.indirect_reference(2)
      iex> catalog = Hopper.Core.Document.catalog(pages_ref)
      iex> is_struct(catalog, Hopper.Core.Objects.Dictionary)
      true

  """
  @spec catalog(IndirectReference.t(), [
          {:version, Objects.Name.t()}
          | {:extensions, Objects.Dictionary.t()}
          | {:page_labels, Objects.Dictionary.t()}
          | {:names, Objects.Dictionary.t()}
          | {:dests, Objects.Dictionary.t()}
          | {:viewer_preferences, Objects.Dictionary.t()}
          | {:page_layout, Objects.Name.t()}
          | {:page_mode, Objects.Name.t()}
          | {:outlines, Objects.Dictionary.t()}
          | {:threads, [Objects.Dictionary.t()]}
          | {:open_action, Objects.Dictionary.t() | list()}
          | {:aa, Objects.Dictionary.t()}
          | {:uri, Objects.Dictionary.t()}
          | {:acro_form, Objects.Dictionary.t()}
          | {:metadata, IndirectReference.t()}
          | {:struct_tree_root, Objects.Dictionary.t()}
          | {:mark_info, Objects.Dictionary.t()}
          | {:lang, Objects.LitString.t()}
          | {:spider_info, Objects.Dictionary.t()}
          | {:output_intents, [Objects.Dictionary.t()]}
          | {:piece_info, Objects.Dictionary.t()}
          | {:oc_properties, Objects.Dictionary.t()}
          | {:perms, Objects.Dictionary.t()}
          | {:legal, Objects.Dictionary.t()}
          | {:requirements, [Objects.Dictionary.t()]}
          | {:collection, Objects.Dictionary.t()}
          | {:needs_rendering, Objects.Boolean.t()}
          | {:dss, Objects.Dictionary.t()}
          | {:af, [IndirectReference.t()]}
          | {:d_part_root, Objects.Dictionary.t()}
        ]) :: Objects.Dictionary.t()
  def catalog(%IndirectReference{} = pages_ref, opts \\ []) do
    [Type: Objects.name("Catalog"), Pages: pages_ref]
    |> maybe_put(:Version, opts[:version])
    |> maybe_put(:Extensions, opts[:extensions])
    |> maybe_put(:PageLabels, opts[:page_labels])
    |> maybe_put(:Names, opts[:names])
    |> maybe_put(:Dests, opts[:dests])
    |> maybe_put(:ViewerPreferences, opts[:viewer_preferences])
    |> maybe_put(:PageLayout, opts[:page_layout])
    |> maybe_put(:PageMode, opts[:page_mode])
    |> maybe_put(:Outlines, opts[:outlines])
    |> maybe_put(:Threads, opts[:threads])
    |> maybe_put(:OpenAction, opts[:open_action])
    |> maybe_put(:AA, opts[:aa])
    |> maybe_put(:URI, opts[:uri])
    |> maybe_put(:AcroForm, opts[:acro_form])
    |> maybe_put(:Metadata, opts[:metadata])
    |> maybe_put(:StructTreeRoot, opts[:struct_tree_root])
    |> maybe_put(:MarkInfo, opts[:mark_info])
    |> maybe_put(:Lang, opts[:lang])
    |> maybe_put(:SpiderInfo, opts[:spider_info])
    |> maybe_put(:OutputIntents, opts[:output_intents])
    |> maybe_put(:PieceInfo, opts[:piece_info])
    |> maybe_put(:OCProperties, opts[:oc_properties])
    |> maybe_put(:Perms, opts[:perms])
    |> maybe_put(:Legal, opts[:legal])
    |> maybe_put(:Requirements, opts[:requirements])
    |> maybe_put(:Collection, opts[:collection])
    |> maybe_put(:NeedsRendering, opts[:needs_rendering])
    |> maybe_put(:DSS, opts[:dss])
    |> maybe_put(:AF, opts[:af])
    |> maybe_put(:DPartRoot, opts[:d_part_root])
    |> Objects.dictionary()
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
    [Type: Objects.name("Pages"), Kids: kids, Count: count]
    |> maybe_put(:Parent, opts[:parent])
    |> Objects.dictionary()
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
    [
      Type: Objects.name("Page"),
      Parent: parent_ref,
      MediaBox: [llx, lly, urx, ury],
      Resources: opts[:resources] || Objects.dictionary([])
    ]
    |> maybe_put(:Contents, opts[:contents])
    |> maybe_put(:Rotate, opts[:rotate])
    |> maybe_put(:CropBox, opts[:crop_box])
    |> Objects.dictionary()
  end

  # Adds `{key, value}` to `acc` only when `value` is not nil.
  defp maybe_put(acc, _key, nil), do: acc
  defp maybe_put(acc, key, value), do: [{key, value} | acc]
end
