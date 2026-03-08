defmodule Hopper.Core.Operators do
  @moduledoc """
  PDF content stream operators (ISO 32000-2 Annex A).

  Each function returns a `%Hopper.Core.Operator{}` struct. Build a content
  stream by passing a list of operators to `Objects.stream/2`, which will
  call `Hopper.Core.Operator.to_iodata/1` on each one automatically.

  ## Example

      alias Hopper.Core.{Operators, Objects}

      operators = [
        Operators.begin_text(),
        Operators.set_font(Objects.name("F1"), 24),
        Operators.move_text(72, 696),
        Operators.show_text(Objects.lit_string("Hello World")),
        Operators.end_text()
      ]

      stream = Objects.stream([], operators)

  """

  alias Hopper.Core.Operator
  alias Hopper.Core.Objects
  alias Objects.{Name, LitString, Dictionary}

  # ---- Graphics state operators (Table 56) ----

  @doc "Save graphics state (`q`)"
  @spec save_graphics_state() :: Operator.t()
  def save_graphics_state, do: %Operator{name: "q"}

  @doc "Restore graphics state (`Q`)"
  @spec restore_graphics_state() :: Operator.t()
  def restore_graphics_state, do: %Operator{name: "Q"}

  @doc "Concatenate matrix to current transformation matrix (`cm`)"
  @spec concat_matrix(number(), number(), number(), number(), number(), number()) :: Operator.t()
  def concat_matrix(a, b, c, d, e, f), do: %Operator{name: "cm", args: [a, b, c, d, e, f]}

  @doc "Set line width (`w`)"
  @spec set_line_width(number()) :: Operator.t()
  def set_line_width(w), do: %Operator{name: "w", args: [w]}

  @doc "Set line cap style (`J`)"
  @spec set_line_cap(integer()) :: Operator.t()
  def set_line_cap(j), do: %Operator{name: "J", args: [j]}

  @doc "Set line join style (`j`)"
  @spec set_line_join(integer()) :: Operator.t()
  def set_line_join(j), do: %Operator{name: "j", args: [j]}

  @doc "Set miter limit (`M`)"
  @spec set_miter_limit(number()) :: Operator.t()
  def set_miter_limit(m), do: %Operator{name: "M", args: [m]}

  @doc "Set line dash pattern (`d`)"
  @spec set_dash_pattern([number()], number()) :: Operator.t()
  def set_dash_pattern(array, phase), do: %Operator{name: "d", args: [array, phase]}

  @doc "Set colour rendering intent (`ri`)"
  @spec set_rendering_intent(Name.t()) :: Operator.t()
  def set_rendering_intent(%Name{} = intent), do: %Operator{name: "ri", args: [intent]}

  @doc "Set flatness tolerance (`i`)"
  @spec set_flatness(number()) :: Operator.t()
  def set_flatness(i), do: %Operator{name: "i", args: [i]}

  @doc "Set parameters from graphics state parameter dictionary (`gs`)"
  @spec set_graphics_state(Name.t()) :: Operator.t()
  def set_graphics_state(%Name{} = name), do: %Operator{name: "gs", args: [name]}

  # ---- Path construction operators (Table 58) ----

  @doc "Begin new subpath (`m`)"
  @spec move_to(number(), number()) :: Operator.t()
  def move_to(x, y), do: %Operator{name: "m", args: [x, y]}

  @doc "Append straight line segment to path (`l`)"
  @spec line_to(number(), number()) :: Operator.t()
  def line_to(x, y), do: %Operator{name: "l", args: [x, y]}

  @doc "Append curved segment to path — three control points (`c`)"
  @spec curve_to(number(), number(), number(), number(), number(), number()) :: Operator.t()
  def curve_to(x1, y1, x2, y2, x3, y3),
    do: %Operator{name: "c", args: [x1, y1, x2, y2, x3, y3]}

  @doc "Append curved segment to path — initial point replicated (`v`)"
  @spec curve_to_v(number(), number(), number(), number()) :: Operator.t()
  def curve_to_v(x2, y2, x3, y3), do: %Operator{name: "v", args: [x2, y2, x3, y3]}

  @doc "Append curved segment to path — final point replicated (`y`)"
  @spec curve_to_y(number(), number(), number(), number()) :: Operator.t()
  def curve_to_y(x1, y1, x3, y3), do: %Operator{name: "y", args: [x1, y1, x3, y3]}

  @doc "Close subpath (`h`)"
  @spec close_path() :: Operator.t()
  def close_path, do: %Operator{name: "h"}

  @doc "Append rectangle to path (`re`)"
  @spec rect(number(), number(), number(), number()) :: Operator.t()
  def rect(x, y, w, h), do: %Operator{name: "re", args: [x, y, w, h]}

  # ---- Path-painting operators (Table 59) ----

  @doc "Stroke path (`S`)"
  @spec stroke() :: Operator.t()
  def stroke, do: %Operator{name: "S"}

  @doc "Close and stroke path (`s`)"
  @spec close_stroke() :: Operator.t()
  def close_stroke, do: %Operator{name: "s"}

  @doc "Fill path using non-zero winding number rule (`f`)"
  @spec fill() :: Operator.t()
  def fill, do: %Operator{name: "f"}

  @doc "Fill path using non-zero winding number rule — deprecated in PDF 2.0 (`F`)"
  @spec fill_compat() :: Operator.t()
  def fill_compat, do: %Operator{name: "F"}

  @doc "Fill path using even-odd rule (`f*`)"
  @spec fill_even_odd() :: Operator.t()
  def fill_even_odd, do: %Operator{name: "f*"}

  @doc "Fill and stroke path using non-zero winding number rule (`B`)"
  @spec fill_stroke() :: Operator.t()
  def fill_stroke, do: %Operator{name: "B"}

  @doc "Fill and stroke path using even-odd rule (`B*`)"
  @spec fill_stroke_even_odd() :: Operator.t()
  def fill_stroke_even_odd, do: %Operator{name: "B*"}

  @doc "Close, fill, and stroke path using non-zero winding number rule (`b`)"
  @spec close_fill_stroke() :: Operator.t()
  def close_fill_stroke, do: %Operator{name: "b"}

  @doc "Close, fill, and stroke path using even-odd rule (`b*`)"
  @spec close_fill_stroke_even_odd() :: Operator.t()
  def close_fill_stroke_even_odd, do: %Operator{name: "b*"}

  @doc "End path without filling or stroking (`n`)"
  @spec end_path() :: Operator.t()
  def end_path, do: %Operator{name: "n"}

  # ---- Clipping path operators (Table 60) ----

  @doc "Set clipping path using non-zero winding number rule (`W`)"
  @spec clip() :: Operator.t()
  def clip, do: %Operator{name: "W"}

  @doc "Set clipping path using even-odd rule (`W*`)"
  @spec clip_even_odd() :: Operator.t()
  def clip_even_odd, do: %Operator{name: "W*"}

  # ---- Text object operators (Table 105) ----

  @doc "Begin text object (`BT`)"
  @spec begin_text() :: Operator.t()
  def begin_text, do: %Operator{name: "BT"}

  @doc "End text object (`ET`)"
  @spec end_text() :: Operator.t()
  def end_text, do: %Operator{name: "ET"}

  # ---- Text state operators (Table 103) ----

  @doc "Set character spacing (`Tc`)"
  @spec set_character_spacing(number()) :: Operator.t()
  def set_character_spacing(tc), do: %Operator{name: "Tc", args: [tc]}

  @doc "Set word spacing (`Tw`)"
  @spec set_word_spacing(number()) :: Operator.t()
  def set_word_spacing(tw), do: %Operator{name: "Tw", args: [tw]}

  @doc "Set horizontal text scaling (`Tz`)"
  @spec set_horizontal_scaling(number()) :: Operator.t()
  def set_horizontal_scaling(tz), do: %Operator{name: "Tz", args: [tz]}

  @doc "Set text leading (`TL`)"
  @spec set_leading(number()) :: Operator.t()
  def set_leading(tl), do: %Operator{name: "TL", args: [tl]}

  @doc "Set text font and size (`Tf`)"
  @spec set_font(Name.t(), number()) :: Operator.t()
  def set_font(%Name{} = font, size) when is_number(size),
    do: %Operator{name: "Tf", args: [font, size]}

  @doc "Set text rendering mode (`Tr`)"
  @spec set_text_rendering_mode(integer()) :: Operator.t()
  def set_text_rendering_mode(tr), do: %Operator{name: "Tr", args: [tr]}

  @doc "Set text rise (`Ts`)"
  @spec set_text_rise(number()) :: Operator.t()
  def set_text_rise(ts), do: %Operator{name: "Ts", args: [ts]}

  # ---- Text-positioning operators (Table 106) ----

  @doc "Move text position (`Td`)"
  @spec move_text(number(), number()) :: Operator.t()
  def move_text(tx, ty) when is_number(tx) and is_number(ty),
    do: %Operator{name: "Td", args: [tx, ty]}

  @doc "Move text position and set leading (`TD`)"
  @spec move_text_leading(number(), number()) :: Operator.t()
  def move_text_leading(tx, ty) when is_number(tx) and is_number(ty),
    do: %Operator{name: "TD", args: [tx, ty]}

  @doc "Set text matrix and text line matrix (`Tm`)"
  @spec set_text_matrix(number(), number(), number(), number(), number(), number()) :: Operator.t()
  def set_text_matrix(a, b, c, d, e, f),
    do: %Operator{name: "Tm", args: [a, b, c, d, e, f]}

  @doc "Move to start of next text line (`T*`)"
  @spec next_line() :: Operator.t()
  def next_line, do: %Operator{name: "T*"}

  # ---- Text-showing operators (Table 107) ----

  @doc "Show text (`Tj`)"
  @spec show_text(LitString.t()) :: Operator.t()
  def show_text(%LitString{} = string), do: %Operator{name: "Tj", args: [string]}

  @doc "Show text, allowing individual glyph positioning (`TJ`). Items are `%LitString{}` structs or numbers (kerning)."
  @spec show_text_array([LitString.t() | number()]) :: Operator.t()
  def show_text_array(items) when is_list(items), do: %Operator{name: "TJ", args: [items]}

  @doc "Move to next line and show text (`'`)"
  @spec next_line_show_text(LitString.t()) :: Operator.t()
  def next_line_show_text(%LitString{} = string), do: %Operator{name: "'", args: [string]}

  @doc "Set word and character spacing, move to next line, and show text (`\"`)"
  @spec set_spacing_next_line_show_text(number(), number(), LitString.t()) :: Operator.t()
  def set_spacing_next_line_show_text(word_space, char_space, %LitString{} = string),
    do: %Operator{name: "\"", args: [word_space, char_space, string]}

  # ---- Colour operators (Table 73) ----

  @doc "Set colour space for stroking operations (`CS`)"
  @spec set_stroking_color_space(Name.t()) :: Operator.t()
  def set_stroking_color_space(%Name{} = name), do: %Operator{name: "CS", args: [name]}

  @doc "Set colour space for nonstroking operations (`cs`)"
  @spec set_nonstroking_color_space(Name.t()) :: Operator.t()
  def set_nonstroking_color_space(%Name{} = name), do: %Operator{name: "cs", args: [name]}

  @doc "Set colour for stroking operations (`SC`)"
  @spec set_stroking_color([number()]) :: Operator.t()
  def set_stroking_color(components) when is_list(components),
    do: %Operator{name: "SC", args: components}

  @doc "Set colour for stroking operations — ICCBased and special colour spaces (`SCN`)"
  @spec set_stroking_color_icc([number()]) :: Operator.t()
  def set_stroking_color_icc(components) when is_list(components),
    do: %Operator{name: "SCN", args: components}

  @doc "Set colour for nonstroking operations (`sc`)"
  @spec set_nonstroking_color([number()]) :: Operator.t()
  def set_nonstroking_color(components) when is_list(components),
    do: %Operator{name: "sc", args: components}

  @doc "Set colour for nonstroking operations — ICCBased and special colour spaces (`scn`)"
  @spec set_nonstroking_color_icc([number()]) :: Operator.t()
  def set_nonstroking_color_icc(components) when is_list(components),
    do: %Operator{name: "scn", args: components}

  @doc "Set gray level for stroking operations (`G`)"
  @spec set_stroking_gray(number()) :: Operator.t()
  def set_stroking_gray(gray), do: %Operator{name: "G", args: [gray]}

  @doc "Set gray level for nonstroking operations (`g`)"
  @spec set_nonstroking_gray(number()) :: Operator.t()
  def set_nonstroking_gray(gray), do: %Operator{name: "g", args: [gray]}

  @doc "Set RGB colour for stroking operations (`RG`)"
  @spec set_stroking_rgb(number(), number(), number()) :: Operator.t()
  def set_stroking_rgb(r, g, b), do: %Operator{name: "RG", args: [r, g, b]}

  @doc "Set RGB colour for nonstroking operations (`rg`)"
  @spec set_nonstroking_rgb(number(), number(), number()) :: Operator.t()
  def set_nonstroking_rgb(r, g, b), do: %Operator{name: "rg", args: [r, g, b]}

  @doc "Set CMYK colour for stroking operations (`K`)"
  @spec set_stroking_cmyk(number(), number(), number(), number()) :: Operator.t()
  def set_stroking_cmyk(c, m, y, k), do: %Operator{name: "K", args: [c, m, y, k]}

  @doc "Set CMYK colour for nonstroking operations (`k`)"
  @spec set_nonstroking_cmyk(number(), number(), number(), number()) :: Operator.t()
  def set_nonstroking_cmyk(c, m, y, k), do: %Operator{name: "k", args: [c, m, y, k]}

  # ---- Shading operator (Table 76) ----

  @doc "Paint area defined by shading pattern (`sh`)"
  @spec shading(Name.t()) :: Operator.t()
  def shading(%Name{} = name), do: %Operator{name: "sh", args: [name]}

  # ---- Inline image operators (Table 90) ----

  @doc "Begin inline image object (`BI`)"
  @spec begin_inline_image() :: Operator.t()
  def begin_inline_image, do: %Operator{name: "BI"}

  @doc "Begin inline image data (`ID`)"
  @spec begin_inline_image_data() :: Operator.t()
  def begin_inline_image_data, do: %Operator{name: "ID"}

  @doc "End inline image object (`EI`)"
  @spec end_inline_image() :: Operator.t()
  def end_inline_image, do: %Operator{name: "EI"}

  # ---- XObject operator (Table 86) ----

  @doc "Invoke named XObject (`Do`)"
  @spec invoke_xobject(Name.t()) :: Operator.t()
  def invoke_xobject(%Name{} = name), do: %Operator{name: "Do", args: [name]}

  # ---- Marked-content operators (Table 352) ----

  @doc "Define marked-content point (`MP`)"
  @spec define_marked_content_point(Name.t()) :: Operator.t()
  def define_marked_content_point(%Name{} = tag), do: %Operator{name: "MP", args: [tag]}

  @doc "Define marked-content point with property list (`DP`). `props` is a `%Name{}` or a `%Dictionary{}`."
  @spec define_marked_content_point_with_props(Name.t(), Name.t() | Dictionary.t()) ::
          Operator.t()
  def define_marked_content_point_with_props(%Name{} = tag, props),
    do: %Operator{name: "DP", args: [tag, props]}

  @doc "Begin marked-content sequence (`BMC`)"
  @spec begin_marked_content(Name.t()) :: Operator.t()
  def begin_marked_content(%Name{} = tag), do: %Operator{name: "BMC", args: [tag]}

  @doc "Begin marked-content sequence with property list (`BDC`). `props` is a `%Name{}` or a `%Dictionary{}`."
  @spec begin_marked_content_with_props(Name.t(), Name.t() | Dictionary.t()) ::
          Operator.t()
  def begin_marked_content_with_props(%Name{} = tag, props),
    do: %Operator{name: "BDC", args: [tag, props]}

  @doc "End marked-content sequence (`EMC`)"
  @spec end_marked_content() :: Operator.t()
  def end_marked_content, do: %Operator{name: "EMC"}

  # ---- Compatibility operators (Table 33) ----

  @doc "Begin compatibility section (`BX`)"
  @spec begin_compatibility() :: Operator.t()
  def begin_compatibility, do: %Operator{name: "BX"}

  @doc "End compatibility section (`EX`)"
  @spec end_compatibility() :: Operator.t()
  def end_compatibility, do: %Operator{name: "EX"}

  # ---- Type 3 font operators (Table 111) ----

  @doc "Set glyph width in Type 3 font (`d0`)"
  @spec set_glyph_width(number(), number()) :: Operator.t()
  def set_glyph_width(wx, wy), do: %Operator{name: "d0", args: [wx, wy]}

  @doc "Set glyph width and bounding box in Type 3 font (`d1`)"
  @spec set_glyph_width_and_bbox(number(), number(), number(), number(), number(), number()) ::
          Operator.t()
  def set_glyph_width_and_bbox(wx, wy, llx, lly, urx, ury),
    do: %Operator{name: "d1", args: [wx, wy, llx, lly, urx, ury]}
end
