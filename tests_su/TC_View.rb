# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen



# class Sketchup::View
# http://www.sketchup.com/intl/developer/docs/ourdoc/view
class TC_View < SUMT::TestCase

  def setup
    @model = Sketchup.active_model
    @view = @model.active_view
  end

  def teardown
    # ...
  end


  # ========================================================================== #
  # method Sketchup::View.draw
  # http://www.sketchup.com/intl/developer/docs/ourdoc/view#draw

  def test_draw_invalid_arguments_zero
    assert_raises(ArgumentError) { @view.draw }
  end

  def test_draw_invalid_arguments_zero_points
    assert_raises(ArgumentError) { @view.draw(GL_POINTS) }
  end


  def test_draw_gl_points_single
    @view.draw(GL_POINTS, ORIGIN)
  end

  def test_draw_gl_points_multiple
    @view.draw(GL_POINTS, ORIGIN, [9,9,9])
  end


  def test_draw_gl_lines_single
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6]]
    @view.draw(GL_LINES, points)
  end

  def test_draw_gl_lines_multiple
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6]]
    @view.draw(GL_LINES, points)
  end

  def test_draw_gl_lines_invalid_arguments
    skip("Fixed in SU2015") if SU_VERS_INT < 15
    points = [ORIGIN, [2,2,2], [4,4,4]]
    assert_raises(ArgumentError) { @view.draw(GL_LINES, points) }
  end


  def test_draw_gl_line_strip_single
    points = [ORIGIN, [2,2,2]]
    @view.draw(GL_LINE_STRIP, points)
  end

  def test_draw_gl_line_strip_multiple
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8]]
    @view.draw(GL_LINE_STRIP, points)
  end

  def test_draw_gl_line_strip_invalid_arguments
    assert_raises(ArgumentError) { @view.draw(GL_LINE_STRIP, [ORIGIN]) }
  end

  def test_draw_gl_line_loop_single
    points = [ORIGIN, [2,2,2]]
    @view.draw(GL_LINE_LOOP, points)
  end

  def test_draw_gl_line_loop_multiple
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8]]
    @view.draw(GL_LINE_LOOP, points)
  end

  def test_draw_gl_line_loop_invalid_arguments
    assert_raises(ArgumentError) { @view.draw(GL_LINE_LOOP, [ORIGIN]) }
  end


  def test_draw_gl_triangles_single
    points = [ORIGIN, [2,2,2], [4,4,4]]
    @view.draw(GL_TRIANGLES, points)
  end

  def test_draw_gl_triangles_multiple
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8], [10,10,10]]
    @view.draw(GL_TRIANGLES, points)
  end

  def test_draw_gl_triangles_invalid_arguments_one
    assert_raises(ArgumentError) { @view.draw(GL_TRIANGLES, [ORIGIN]) }
  end

  def test_draw_gl_triangles_invalid_arguments_two
    points = [ORIGIN, [2,2,2]]
    assert_raises(ArgumentError) { @view.draw(GL_TRIANGLES, points) }
  end

  def test_draw_gl_triangles_invalid_arguments_four
    skip("Fixed in SU2015") if SU_VERS_INT < 15
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6]]
    assert_raises(ArgumentError) { @view.draw(GL_TRIANGLES, points) }
  end

  def test_draw_gl_triangles_invalid_arguments_five
    skip("Fixed in SU2015") if SU_VERS_INT < 15
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8]]
    assert_raises(ArgumentError) { @view.draw(GL_TRIANGLES, points) }
  end

  def test_draw_gl_triangle_strip_single
    points = [ORIGIN, [2,2,2], [4,4,4]]
    @view.draw(GL_TRIANGLE_STRIP, points)
  end

  def test_draw_gl_triangle_strip_multiple
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8]]
    @view.draw(GL_TRIANGLE_STRIP, points)
  end

  def test_draw_gl_triangle_strip_invalid_arguments_one
    assert_raises(ArgumentError) { @view.draw(GL_TRIANGLE_STRIP, [ORIGIN]) }
  end

  def test_draw_gl_triangle_strip_invalid_arguments_two
    points = [ORIGIN, [2,2,2]]
    assert_raises(ArgumentError) { @view.draw(GL_TRIANGLE_STRIP, points) }
  end


  def test_draw_gl_triangle_fan_single
    points = [ORIGIN, [2,2,2], [4,4,4]]
    @view.draw(GL_TRIANGLE_FAN, points)
  end

  def test_draw_gl_triangle_fan_multiple
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8]]
    @view.draw(GL_TRIANGLE_FAN, points)
  end

  def test_draw_gl_triangle_fan_invalid_arguments_one
    assert_raises(ArgumentError) { @view.draw(GL_TRIANGLE_FAN, [ORIGIN]) }
  end

  def test_draw_gl_triangle_fan_invalid_arguments_two
    points = [ORIGIN, [2,2,2]]
    assert_raises(ArgumentError) { @view.draw(GL_TRIANGLE_FAN, points) }
  end


  def test_draw_gl_quads_single
    points = [ORIGIN, [2,0,0], [2,2,0], [0,2,0]]
    @view.draw(GL_QUADS, points)
  end

  def test_draw_gl_quads_multiple
    points = [
      ORIGIN, [2,2,2], [4,4,4], [6,6,6],
      [8,8,8], [10,10,10], [12,12,12], [14,14,14]
    ]
    @view.draw(GL_QUADS, points)
  end

  def test_draw_gl_quads_invalid_arguments_one
    assert_raises(ArgumentError) { @view.draw(GL_QUADS, [ORIGIN]) }
  end

  def test_draw_gl_quads_invalid_arguments_two
    assert_raises(ArgumentError) { @view.draw(GL_QUADS, [ORIGIN, [2,2,2]]) }
  end

  def test_draw_gl_quads_invalid_arguments_three
    points = [ORIGIN, [2,2,2], [4,4,4]]
    assert_raises(ArgumentError) { @view.draw(GL_QUADS, points) }
  end

  def test_draw_gl_quads_invalid_arguments_five
    skip("Fixed in SU2015") if SU_VERS_INT < 15
    points = [
      ORIGIN, [2,2,2], [4,4,4], [6,6,6],
      [8,8,8]
    ]
    assert_raises(ArgumentError) { @view.draw(GL_QUADS, points) }
  end

  def test_draw_gl_quads_invalid_arguments_six
    skip("Fixed in SU2015") if SU_VERS_INT < 15
    points = [
      ORIGIN, [2,2,2], [4,4,4], [6,6,6],
      [8,8,8], [10,10,10]
    ]
    assert_raises(ArgumentError) { @view.draw(GL_QUADS, points) }
  end

  def test_draw_gl_quads_invalid_arguments_seven
    skip("Fixed in SU2015") if SU_VERS_INT < 15
    points = [
      ORIGIN, [2,2,2], [4,4,4], [6,6,6],
      [8,8,8], [10,10,10], [12,12,12]
    ]
    assert_raises(ArgumentError) { @view.draw(GL_QUADS, points) }
  end


  def test_draw_gl_quad_strip_single
    points = [ORIGIN, [2,0,0], [2,2,0], [0,2,0]]
    @view.draw(GL_QUAD_STRIP, points)
  end

  def test_draw_gl_quad_strip_multiple
    points = [
      ORIGIN, [2,2,2], [4,4,4], [6,6,6],
      [8,8,8], [10,10,10]
    ]
    @view.draw(GL_QUAD_STRIP, points)
  end

  def test_draw_gl_quad_strip_invalid_arguments_one
    assert_raises(ArgumentError) { @view.draw(GL_QUAD_STRIP, [ORIGIN]) }
  end

  def test_draw_gl_quad_strip_invalid_arguments_two
    points = [ORIGIN, [2,2,2]]
    assert_raises(ArgumentError) { @view.draw(GL_QUAD_STRIP, points) }
  end

  def test_draw_gl_quad_strip_invalid_arguments_three
    points = [ORIGIN, [2,2,2], [4,4,4]]
    assert_raises(ArgumentError) { @view.draw(GL_QUAD_STRIP, points) }
  end

  def test_draw_gl_quad_strip_invalid_arguments_five
    skip("Fixed in SU2015") if SU_VERS_INT < 15
    points = [
      ORIGIN, [2,2,2], [4,4,4], [6,6,6],
      [8,8,8]
    ]
    assert_raises(ArgumentError){ @view.draw(GL_QUAD_STRIP, points) }
  end

  def test_draw_gl_quad_strip_invalid_arguments_seven
    skip("Fixed in SU2015") if SU_VERS_INT < 15
    points = [
      ORIGIN, [2,2,2], [4,4,4], [6,6,6],
      [8,8,8], [10,10,10], [12,12,12]
    ]
    assert_raises(ArgumentError) { @view.draw(GL_QUAD_STRIP, points) }
  end


  def test_draw_gl_polygon_triangle
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6]]
    @view.draw(GL_POLYGON, points)
  end

  def test_draw_gl_polygon_quad
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6]]
    @view.draw(GL_POLYGON, points)
  end

  def test_draw_gl_polygon_pentagon
    points = [ORIGIN, [2,2,2], [4,4,4], [6,6,6], [8,8,8]]
    @view.draw(GL_POLYGON, points)
  end

  def test_draw_gl_polygon_invalid_arguments_one
    points = [ORIGIN]
    assert_raises(ArgumentError) { @view.draw(GL_POLYGON, points) }
  end

  def test_draw_gl_polygon_invalid_arguments_two
    points = [ORIGIN, [2,2,2]]
    assert_raises(ArgumentError) { @view.draw(GL_POLYGON, points) }
  end


  # ========================================================================== #
  # method Sketchup::View.draw_text
  # http://www.sketchup.com/intl/developer/docs/ourdoc/view#draw_text

  def test_draw_text_api_example
    view = Sketchup.active_model.active_view

    # This works in all SketchUp versions and draws the text using the
    # default font, color and size.
    point = Geom::Point3d.new(200, 100, 0)
    view.draw_text(point, "This is a test")

    # This works in SketchUp 2016 and up.
    options = {
      :font => "Arial",
      :size => 20,
      :bold => true,
      :align => TextAlignRight
    }
    point = Geom::Point3d.new(200, 200, 0)
    view.draw_text(point, "This is another\ntest", options)

    # You can also use Ruby 2.0's named arguments:
    point = Geom::Point3d.new(200, 200, 0)
    view.draw_text(point, "Hello world!", color: "Red")
  end

  def test_draw_text
    assert_equal @view, @view.draw_text(ORIGIN, "Test")
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_invalid_argument_position
    assert_raises(ArgumentError) { @view.draw_text "FooBar", "Test" }
  end

  def test_draw_invalid_arguments_zero
    assert_raises(ArgumentError) { @view.draw_text }
  end

  def test_draw_invalid_arguments_one
    assert_raises(ArgumentError) { @view.draw_text ORIGIN }
  end

  def test_draw_invalid_arguments_three
    skip("Optional argument added in SU2016") if SU_VERS_INT >= 16 
    assert_raises(TypeError) { @view.draw_text ORIGIN, "Test", 123  }
  end

  def test_draw_invalid_arguments_four
    assert_raises(ArgumentError) { @view.draw_text ORIGIN, "Test", 123, 456  }
  end

  def test_draw_text_options_argument
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_equal @view, @view.draw_text(ORIGIN, "Test", {})
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_options_invalid_argument
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_raises(TypeError) { @view.draw_text ORIGIN, "Test", ORIGIN }
  end

  def test_draw_text_option_font
    skip("Added in SU2016") if SU_VERS_INT < 16
    options = {
      :font => "Arial"
    }
    assert_equal @view, @view.draw_text(ORIGIN, "Test", options)
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_font_bogus_name
    skip("Added in SU2016") if SU_VERS_INT < 16
    options = {
      :font => "IamNotAFontButShouldNotCrash"
    }
    assert_equal @view, @view.draw_text(ORIGIN, "Test", options)
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_font_long_name
    skip("Added in SU2016") if SU_VERS_INT < 16
    options = {
      :font => "ThisFontNameIsTooLongForWindows01234"
    }
    if Sketchup.platform == :platform_osx
      assert_equal @view, @view.draw_text(ORIGIN, "Test", options)
    else
      assert_raises(ArgumentError) { @view.draw_text ORIGIN, "Test", options }
    end
  end

  def test_draw_text_option_font_name_unicode
    skip("Added in SU2016") if SU_VERS_INT < 16
    options = {
      :font => "Tæsting てすと"
    }
    assert_equal @view, @view.draw_text(ORIGIN, "てすと", options)
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_font_invalid_argument
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_raises(TypeError) { @view.draw_text ORIGIN, "Test", font: ORIGIN }
  end

  def test_draw_text_option_size
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_equal @view, @view.draw_text(ORIGIN, "Test", size: 20)
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_size_zero
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_equal @view, @view.draw_text(ORIGIN, "Test", size: 0)
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_size_invalid_argument
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_raises(TypeError) { @view.draw_text(ORIGIN, "Test", size: "FooBar") }
  end

  def test_draw_text_option_italic
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_equal @view, @view.draw_text(ORIGIN, "Test", italic: true)
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_bold
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_equal @view, @view.draw_text(ORIGIN, "Test", bold: true)
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_color
    skip("Added in SU2016") if SU_VERS_INT < 16
    color = Sketchup::Color.new(255, 0, 0)
    assert_equal @view, @view.draw_text(ORIGIN, "Test", color: color)
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_color_string
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_equal @view, @view.draw_text(ORIGIN, "Test", color: "red")
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_color_invalid_argument
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_raises(TypeError) { @view.draw_text(ORIGIN, "Test", color: ORIGIN) }
  end

  def test_draw_text_option_align_left
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_equal @view, @view.draw_text(ORIGIN, "Test", align: TextAlignLeft)
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_align_center
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_equal @view, @view.draw_text(ORIGIN, "Test", align: TextAlignCenter)
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_align_right
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_equal @view, @view.draw_text(ORIGIN, "Test", align: TextAlignRight)
    @view.refresh # Force a redraw to check if anything crashes.
  end

  def test_draw_text_option_align_invalid_integer_less_than
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_raises(ArgumentError) { @view.draw_text(ORIGIN, "Test", align: -1) }
  end

  def test_draw_text_option_align_invalid_integer_higher_than
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_raises(ArgumentError) { @view.draw_text(ORIGIN, "Test", align: 3) }
  end

  def test_draw_text_option_align_invalid_symbol
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_raises(TypeError) { @view.draw_text(ORIGIN, "Test", align: :foobar) }
  end

  def test_draw_text_option_align_invalid_argument
    skip("Added in SU2016") if SU_VERS_INT < 16
    assert_raises(TypeError) { @view.draw_text(ORIGIN, "Test", align: ORIGIN) }
  end

end # class
