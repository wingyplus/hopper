defmodule Hopper.Core.OperatorsTest do
  use ExUnit.Case, async: true

  alias Hopper.Core.{Operators, Objects}

  defp render(op), do: IO.iodata_to_binary(Hopper.Core.Operator.to_iodata(op))

  # ---- Graphics state operators ----

  describe "save_graphics_state/0" do
    test "emits q" do
      assert render(Operators.save_graphics_state()) == "q\n"
    end
  end

  describe "restore_graphics_state/0" do
    test "emits Q" do
      assert render(Operators.restore_graphics_state()) == "Q\n"
    end
  end

  describe "concat_matrix/6" do
    test "integer operands" do
      assert render(Operators.concat_matrix(1, 0, 0, 1, 100, 200)) == "1 0 0 1 100 200 cm\n"
    end

    test "float operands" do
      assert render(Operators.concat_matrix(0.5, 0.0, 0.0, 0.5, 0.0, 0.0)) ==
               "0.5 0.0 0.0 0.5 0.0 0.0 cm\n"
    end
  end

  describe "set_line_width/1" do
    test "integer" do
      assert render(Operators.set_line_width(2)) == "2 w\n"
    end

    test "float" do
      assert render(Operators.set_line_width(0.5)) == "0.5 w\n"
    end
  end

  describe "set_line_cap/1" do
    test "emits J" do
      assert render(Operators.set_line_cap(1)) == "1 J\n"
    end
  end

  describe "set_line_join/1" do
    test "emits j" do
      assert render(Operators.set_line_join(2)) == "2 j\n"
    end
  end

  describe "set_miter_limit/1" do
    test "emits M" do
      assert render(Operators.set_miter_limit(10)) == "10 M\n"
    end
  end

  describe "set_dash_pattern/2" do
    test "with array and phase" do
      assert render(Operators.set_dash_pattern([3, 2], 0)) == "[3 2] 0 d\n"
    end

    test "empty array (solid line)" do
      assert render(Operators.set_dash_pattern([], 0)) == "[] 0 d\n"
    end
  end

  describe "set_rendering_intent/1" do
    test "emits ri" do
      assert render(Operators.set_rendering_intent(Objects.name("RelativeColorimetric"))) ==
               "/RelativeColorimetric ri\n"
    end
  end

  describe "set_flatness/1" do
    test "emits i" do
      assert render(Operators.set_flatness(1)) == "1 i\n"
    end
  end

  describe "set_graphics_state/1" do
    test "emits gs" do
      assert render(Operators.set_graphics_state(Objects.name("GS1"))) == "/GS1 gs\n"
    end
  end

  # ---- Path construction operators ----

  describe "move_to/2" do
    test "emits m" do
      assert render(Operators.move_to(10, 20)) == "10 20 m\n"
    end
  end

  describe "line_to/2" do
    test "emits l" do
      assert render(Operators.line_to(100, 200)) == "100 200 l\n"
    end
  end

  describe "curve_to/6" do
    test "emits c" do
      assert render(Operators.curve_to(1, 2, 3, 4, 5, 6)) == "1 2 3 4 5 6 c\n"
    end
  end

  describe "curve_to_v/4" do
    test "emits v" do
      assert render(Operators.curve_to_v(3, 4, 5, 6)) == "3 4 5 6 v\n"
    end
  end

  describe "curve_to_y/4" do
    test "emits y" do
      assert render(Operators.curve_to_y(1, 2, 5, 6)) == "1 2 5 6 y\n"
    end
  end

  describe "close_path/0" do
    test "emits h" do
      assert render(Operators.close_path()) == "h\n"
    end
  end

  describe "rect/4" do
    test "emits re" do
      assert render(Operators.rect(10, 20, 200, 100)) == "10 20 200 100 re\n"
    end
  end

  # ---- Path-painting operators ----

  describe "stroke/0" do
    test "emits S" do
      assert render(Operators.stroke()) == "S\n"
    end
  end

  describe "close_stroke/0" do
    test "emits s" do
      assert render(Operators.close_stroke()) == "s\n"
    end
  end

  describe "fill/0" do
    test "emits f" do
      assert render(Operators.fill()) == "f\n"
    end
  end

  describe "fill_compat/0" do
    test "emits F" do
      assert render(Operators.fill_compat()) == "F\n"
    end
  end

  describe "fill_even_odd/0" do
    test "emits f*" do
      assert render(Operators.fill_even_odd()) == "f*\n"
    end
  end

  describe "fill_stroke/0" do
    test "emits B" do
      assert render(Operators.fill_stroke()) == "B\n"
    end
  end

  describe "fill_stroke_even_odd/0" do
    test "emits B*" do
      assert render(Operators.fill_stroke_even_odd()) == "B*\n"
    end
  end

  describe "close_fill_stroke/0" do
    test "emits b" do
      assert render(Operators.close_fill_stroke()) == "b\n"
    end
  end

  describe "close_fill_stroke_even_odd/0" do
    test "emits b*" do
      assert render(Operators.close_fill_stroke_even_odd()) == "b*\n"
    end
  end

  describe "end_path/0" do
    test "emits n" do
      assert render(Operators.end_path()) == "n\n"
    end
  end

  # ---- Clipping path operators ----

  describe "clip/0" do
    test "emits W" do
      assert render(Operators.clip()) == "W\n"
    end
  end

  describe "clip_even_odd/0" do
    test "emits W*" do
      assert render(Operators.clip_even_odd()) == "W*\n"
    end
  end

  # ---- Text object operators ----

  describe "begin_text/0" do
    test "emits BT" do
      assert render(Operators.begin_text()) == "BT\n"
    end
  end

  describe "end_text/0" do
    test "emits ET" do
      assert render(Operators.end_text()) == "ET\n"
    end
  end

  # ---- Text state operators ----

  describe "set_character_spacing/1" do
    test "emits Tc" do
      assert render(Operators.set_character_spacing(0)) == "0 Tc\n"
    end
  end

  describe "set_word_spacing/1" do
    test "emits Tw" do
      assert render(Operators.set_word_spacing(2)) == "2 Tw\n"
    end
  end

  describe "set_horizontal_scaling/1" do
    test "emits Tz" do
      assert render(Operators.set_horizontal_scaling(100)) == "100 Tz\n"
    end
  end

  describe "set_leading/1" do
    test "emits TL" do
      assert render(Operators.set_leading(14)) == "14 TL\n"
    end
  end

  describe "set_font/2" do
    test "emits Tf with name and size" do
      assert render(Operators.set_font(Objects.name("F1"), 12)) == "/F1 12 Tf\n"
    end
  end

  describe "set_text_rendering_mode/1" do
    test "emits Tr" do
      assert render(Operators.set_text_rendering_mode(0)) == "0 Tr\n"
    end
  end

  describe "set_text_rise/1" do
    test "emits Ts" do
      assert render(Operators.set_text_rise(5)) == "5 Ts\n"
    end
  end

  # ---- Text-positioning operators ----

  describe "move_text/2" do
    test "emits Td" do
      assert render(Operators.move_text(72, 696)) == "72 696 Td\n"
    end
  end

  describe "move_text_leading/2" do
    test "emits TD" do
      assert render(Operators.move_text_leading(0, -14)) == "0 -14 TD\n"
    end
  end

  describe "set_text_matrix/6" do
    test "emits Tm" do
      assert render(Operators.set_text_matrix(1, 0, 0, 1, 72, 720)) == "1 0 0 1 72 720 Tm\n"
    end
  end

  describe "next_line/0" do
    test "emits T*" do
      assert render(Operators.next_line()) == "T*\n"
    end
  end

  # ---- Text-showing operators ----

  describe "show_text/1" do
    test "emits Tj with literal string" do
      assert render(Operators.show_text(Objects.lit_string("Hello"))) == "(Hello) Tj\n"
    end

    test "escapes parentheses in string" do
      assert render(Operators.show_text(Objects.lit_string("(test)"))) == "(\\(test\\)) Tj\n"
    end
  end

  describe "show_text_array/1" do
    test "emits TJ with mixed strings and numbers" do
      assert render(
               Operators.show_text_array([Objects.lit_string("Hello"), -10, Objects.lit_string("World")])
             ) == "[(Hello) -10 (World)] TJ\n"
    end

    test "emits TJ with only strings" do
      assert render(Operators.show_text_array([Objects.lit_string("Hi")])) == "[(Hi)] TJ\n"
    end
  end

  describe "next_line_show_text/1" do
    test "emits '" do
      assert render(Operators.next_line_show_text(Objects.lit_string("Hello"))) == "(Hello) '\n"
    end
  end

  describe "set_spacing_next_line_show_text/3" do
    test "emits \"" do
      assert render(Operators.set_spacing_next_line_show_text(2, 1, Objects.lit_string("Hello"))) ==
               "2 1 (Hello) \"\n"
    end
  end

  # ---- Colour operators ----

  describe "set_stroking_color_space/1" do
    test "emits CS" do
      assert render(Operators.set_stroking_color_space(Objects.name("DeviceRGB"))) ==
               "/DeviceRGB CS\n"
    end
  end

  describe "set_nonstroking_color_space/1" do
    test "emits cs" do
      assert render(Operators.set_nonstroking_color_space(Objects.name("DeviceGray"))) ==
               "/DeviceGray cs\n"
    end
  end

  describe "set_stroking_color/1" do
    test "emits SC with single component" do
      assert render(Operators.set_stroking_color([0.5])) == "0.5 SC\n"
    end

    test "emits SC with RGB components" do
      assert render(Operators.set_stroking_color([1, 0, 0])) == "1 0 0 SC\n"
    end
  end

  describe "set_stroking_color_icc/1" do
    test "emits SCN" do
      assert render(Operators.set_stroking_color_icc([0.1, 0.2, 0.3])) == "0.1 0.2 0.3 SCN\n"
    end
  end

  describe "set_nonstroking_color/1" do
    test "emits sc" do
      assert render(Operators.set_nonstroking_color([0.5])) == "0.5 sc\n"
    end
  end

  describe "set_nonstroking_color_icc/1" do
    test "emits scn" do
      assert render(Operators.set_nonstroking_color_icc([0.5])) == "0.5 scn\n"
    end
  end

  describe "set_stroking_gray/1" do
    test "emits G" do
      assert render(Operators.set_stroking_gray(0)) == "0 G\n"
    end
  end

  describe "set_nonstroking_gray/1" do
    test "emits g" do
      assert render(Operators.set_nonstroking_gray(1)) == "1 g\n"
    end
  end

  describe "set_stroking_rgb/3" do
    test "emits RG" do
      assert render(Operators.set_stroking_rgb(1, 0, 0)) == "1 0 0 RG\n"
    end
  end

  describe "set_nonstroking_rgb/3" do
    test "emits rg" do
      assert render(Operators.set_nonstroking_rgb(0, 1, 0)) == "0 1 0 rg\n"
    end
  end

  describe "set_stroking_cmyk/4" do
    test "emits K" do
      assert render(Operators.set_stroking_cmyk(0, 0, 0, 1)) == "0 0 0 1 K\n"
    end
  end

  describe "set_nonstroking_cmyk/4" do
    test "emits k" do
      assert render(Operators.set_nonstroking_cmyk(0, 0, 0, 0)) == "0 0 0 0 k\n"
    end
  end

  # ---- Shading operator ----

  describe "shading/1" do
    test "emits sh" do
      assert render(Operators.shading(Objects.name("Sh1"))) == "/Sh1 sh\n"
    end
  end

  # ---- Inline image operators ----

  describe "begin_inline_image/0" do
    test "emits BI" do
      assert render(Operators.begin_inline_image()) == "BI\n"
    end
  end

  describe "begin_inline_image_data/0" do
    test "emits ID" do
      assert render(Operators.begin_inline_image_data()) == "ID\n"
    end
  end

  describe "end_inline_image/0" do
    test "emits EI" do
      assert render(Operators.end_inline_image()) == "EI\n"
    end
  end

  # ---- XObject operator ----

  describe "invoke_xobject/1" do
    test "emits Do" do
      assert render(Operators.invoke_xobject(Objects.name("Im1"))) == "/Im1 Do\n"
    end
  end

  # ---- Marked-content operators ----

  describe "define_marked_content_point/1" do
    test "emits MP" do
      assert render(Operators.define_marked_content_point(Objects.name("Tag"))) == "/Tag MP\n"
    end
  end

  describe "define_marked_content_point_with_props/2" do
    test "emits DP with name props" do
      assert render(
               Operators.define_marked_content_point_with_props(
                 Objects.name("Tag"),
                 Objects.name("Props")
               )
             ) == "/Tag /Props DP\n"
    end

    test "emits DP with dictionary props" do
      dict = Objects.dictionary([{"Key", 1}])

      assert render(
               Operators.define_marked_content_point_with_props(Objects.name("Tag"), dict)
             ) == "/Tag << /Key 1 >> DP\n"
    end
  end

  describe "begin_marked_content/1" do
    test "emits BMC" do
      assert render(Operators.begin_marked_content(Objects.name("Span"))) == "/Span BMC\n"
    end
  end

  describe "begin_marked_content_with_props/2" do
    test "emits BDC with name props" do
      assert render(
               Operators.begin_marked_content_with_props(
                 Objects.name("Span"),
                 Objects.name("Props")
               )
             ) == "/Span /Props BDC\n"
    end

    test "emits BDC with dictionary props" do
      dict = Objects.dictionary([{"Lang", Objects.lit_string("en")}])

      assert render(Operators.begin_marked_content_with_props(Objects.name("Span"), dict)) ==
               "/Span << /Lang (en) >> BDC\n"
    end
  end

  describe "end_marked_content/0" do
    test "emits EMC" do
      assert render(Operators.end_marked_content()) == "EMC\n"
    end
  end

  # ---- Compatibility operators ----

  describe "begin_compatibility/0" do
    test "emits BX" do
      assert render(Operators.begin_compatibility()) == "BX\n"
    end
  end

  describe "end_compatibility/0" do
    test "emits EX" do
      assert render(Operators.end_compatibility()) == "EX\n"
    end
  end

  # ---- Type 3 font operators ----

  describe "set_glyph_width/2" do
    test "emits d0" do
      assert render(Operators.set_glyph_width(500, 0)) == "500 0 d0\n"
    end
  end

  describe "set_glyph_width_and_bbox/6" do
    test "emits d1" do
      assert render(Operators.set_glyph_width_and_bbox(500, 0, 0, 0, 400, 700)) ==
               "500 0 0 0 400 700 d1\n"
    end
  end

  # ---- Integration: compose a simple text stream ----

  test "composing a text content stream" do
    operators = [
      Operators.begin_text(),
      Operators.set_font(Objects.name("F1"), 24),
      Operators.move_text(72, 696),
      Operators.show_text(Objects.lit_string("Hello World")),
      Operators.end_text()
    ]

    content = operators |> Enum.map(&Hopper.Core.Operator.to_iodata/1) |> IO.iodata_to_binary()
    assert content == "BT\n/F1 24 Tf\n72 696 Td\n(Hello World) Tj\nET\n"

    stream = Objects.stream([], operators)
    assert is_struct(stream, Hopper.Core.Objects.Stream)
  end
end
