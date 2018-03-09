# frozen_string_literal: true

# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Thomas Thomassen

=begin
SUMT.run %w[TC_Axes.rb]
=end


# class Sketchup::Axes
# http://ruby.sketchup.com/Sketchup/Axes.html
class TC_Axes < SUMT::TestCase

  # Utility class to capture observer events.
  class SUMTModelObserver < Sketchup::ModelObserver
    include SUMT::ObserverEvtToHsh
  end

  def setup
    start_with_empty_model
    @model = Sketchup.active_model
    @axes  = @model.axes
  end

  # ========================================================================== #
  # method Sketchup::Axes.origin
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#origin

  def test_origin_api_example
    point = @model.axes.origin
  end

  def test_origin
    result = @model.axes.origin
    assert_kind_of(Geom::Point3d, result)
  end

  def test_origin_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       @model.axes.origin(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.axes
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#axes

  def test_axes_api_example
    xaxis, yaxis, zaxis = @model.axes.axes
  end

  def test_axes
    result = @model.axes.axes
    assert_kind_of(Array, result)
    assert_equal(3, result.size)
    assert_kind_of(Geom::Vector3d, result[0])
    assert_kind_of(Geom::Vector3d, result[1])
    assert_kind_of(Geom::Vector3d, result[2])
  end

  def test_axes_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       @model.axes.axes(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.xaxis
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#xaxis

  def test_xaxis_api_example
    point = @model.axes.xaxis
  end

  def test_xaxis
    result = @model.axes.xaxis
    assert_kind_of(Geom::Vector3d, result)
    assert(result.valid?)
  end

  def test_xaxis_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       @model.axes.xaxis(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.yaxis
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#yaxis

  def test_yaxis_api_example
    point = @model.axes.yaxis
  end

  def test_yaxis
    result = @model.axes.yaxis
    assert_kind_of(Geom::Vector3d, result)
    assert(result.valid?)
  end

  def test_yaxis_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       @model.axes.yaxis(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.zaxis
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#zaxis

  def test_zaxis_api_example
    point = @model.axes.zaxis
  end

  def test_zaxis
    result = @model.axes.zaxis
    assert_kind_of(Geom::Vector3d, result)
    assert(result.valid?)
  end

  def test_zaxis_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       @model.axes.zaxis(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.transformation
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#transformation

  def test_transformation_api_example
    # Point for a rectangle.
    points = [
      Geom::Point3d.new( 0,  0, 0),
      Geom::Point3d.new(10,  0, 0),
      Geom::Point3d.new(10, 20, 0),
      Geom::Point3d.new( 0, 20, 0)
    ]
    # Transform the points so they are local to the model axes. Otherwise
    # they would be local to the model origin.
    tr = @model.axes.transformation
    points.each { |point| point.transform!(tr) }
    @model.active_entities.add_face(points)
  end

  def test_transformation
    result = @model.axes.transformation
    assert_kind_of(Geom::Transformation, result)
  end

  def test_transformation_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       @model.axes.transformation(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.sketch_plane
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#sketch_plane

  def test_sketch_plane_api_example
    xaxis, yaxis, zaxis = @model.axes.sketch_plane
  end

  def test_sketch_plane
    result = @model.axes.sketch_plane
    assert_kind_of(Array, result)
    assert_equal(4, result.size)
    assert_kind_of(Float, result[0])
    assert_kind_of(Float, result[1])
    assert_kind_of(Float, result[2])
    assert_kind_of(Float, result[3])
  end

  def test_sketch_plane_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       @model.axes.sketch_plane(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.set
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#set

  def test_set_api_example
    xaxis = Geom::Vector3d.new(3, 5, 0)
    yaxis = xaxis * Z_AXIS
    @model.axes.set([10,0,0], xaxis, yaxis, Z_AXIS)
  end

  def test_set_axes_parent_to_model
    model_observer = SUMTModelObserver.new
    @model.add_observer(model_observer)

    result = nil
    thr = Thread.new {
      xaxis = Geom::Vector3d.new(3, 5, 0)
      yaxis = xaxis * Z_AXIS
      result = @model.axes.set([10, 0, 0], xaxis, yaxis, Z_AXIS)
      sleep 0.5
    }
    thr.join

    assert_equal(@model.axes, result)

    assert_obs_event  :onTransactionStart , @model
    assert_obs_event  :onTransactionCommit, @model
    assert_obs_events 2

    origin = @model.axes.origin
    assert_equal(Geom::Point3d.new(10, 0, 0), origin)

    xaxis, yaxis, zaxis = @model.axes.axes
    assert_equal(Geom::Vector3d.new(3,  5, 0).normalize, xaxis)
    assert_equal(Geom::Vector3d.new(5, -3, 0).normalize, yaxis)
    assert_equal(Geom::Vector3d.new(0,  0, 1).normalize, zaxis)

  ensure
    @model.remove_observer(model_observer)
    model_observer = nil
  end

  def test_set_axes_parent_to_page
    page = @model.pages.add("Example Page")

    model_observer = SUMTModelObserver.new
    @model.add_observer(model_observer)

    xaxis = Geom::Vector3d.new(3, 5, 0)
    yaxis = xaxis * Z_AXIS
    result = page.axes.set([10, 0, 0], xaxis, yaxis, Z_AXIS)
    assert_equal(page.axes, result)

    assert_obs_events 0

    origin = page.axes.origin
    assert_equal(Geom::Point3d.new(10, 0, 0), origin)

    xaxis, yaxis, zaxis = page.axes.axes
    assert_equal(Geom::Vector3d.new(3,  5, 0).normalize, xaxis)
    assert_equal(Geom::Vector3d.new(5, -3, 0).normalize, yaxis)
    assert_equal(Geom::Vector3d.new(0,  0, 1).normalize, zaxis)

  ensure
    @model.remove_observer(model_observer)
    model_observer = nil
  end

  def test_set_incorrect_number_of_arguments_zero
    assert_raises ArgumentError do
       @model.axes.set
    end
  end

  def test_set_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       @model.axes.set(ORIGIN)
    end
  end

  def test_set_incorrect_number_of_arguments_two
    assert_raises ArgumentError do
       @model.axes.set(ORIGIN, X_AXIS)
    end
  end

  def test_set_incorrect_number_of_arguments_three
    assert_raises ArgumentError do
       @model.axes.set(ORIGIN, X_AXIS, Y_AXIS)
    end
  end

  def test_set_incorrect_number_of_arguments_five
    assert_raises ArgumentError do
       @model.axes.set(ORIGIN, X_AXIS, Y_AXIS, Z_AXIS, X_AXIS)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.to_a
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#to_a

  def test_to_a_api_example
    xaxis, yaxis, zaxis = @model.axes.to_a
  end

  def test_to_a
    result = @model.axes.to_a
    assert_kind_of(Array, result)
    assert_equal(4, result.size)
    assert_kind_of(Geom::Point3d,  result[0])
    assert_kind_of(Geom::Vector3d, result[1])
    assert_kind_of(Geom::Vector3d, result[2])
    assert_kind_of(Geom::Vector3d, result[3])
  end

  def test_to_a_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       @model.axes.to_a(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Axes.typename
  # http://www.sketchup.com/intl/developer/docs/ourdoc/axes#typename

  def test_typename_api_example
    xaxis, yaxis, zaxis = @model.axes.typename
  end

  def test_typename
    result = @model.axes.typename
    assert_kind_of(String, result)
    assert_equal("Axes", result)
  end

  def test_typename_incorrect_number_of_arguments_one
    assert_raises ArgumentError do
       @model.axes.typename(123)
    end
  end


end # class
