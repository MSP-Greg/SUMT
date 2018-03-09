# Copyright:: Copyright 2016 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Paul Ballew



# class Sketchup::PickHelper
# http://www.sketchup.com/intl/en/developer/docs/ourdoc/pickhelper
class TC_PickHelper < SUMT::TestCase

  # Set this to true to enable verbose debugging output.
  DEBUG_OUTPUT = false

  # Handy constants
  ORIGIN_POINT   = Geom::Point3d.new(  0,   0, 0)
  START_POINT    = Geom::Point3d.new( 10,  10, 0)
  END_POINT      = Geom::Point3d.new(800, 500, 0)
  NEAR_POINT     = Geom::Point3d.new(  1,   1, 0)
  NEGATIVE_POINT = Geom::Point3d.new(-10, -10, 0)
  Z_POINT        = Geom::Point3d.new(  0,   0, 100)
  FAR_POINT = Geom::Point3d.new(9999999, 9999999, 0)
  
  def setup
    start_with_empty_model
    setup_camera
    @pick_helper = Sketchup.active_model.active_view.pick_helper

    if DEBUG_OUTPUT
      puts 'Setup'
      puts "> #{@pick_helper.inspect}"
      puts "> Count: #{@pick_helper.count}"
      puts "> All Picked Size: #{@pick_helper.all_picked.size}"
      puts "> All Picked: #{@pick_helper.all_picked.inspect}"
    end
  end

  def teardown
    #Sketchup.active_model.active_view.camera.aspect_ratio = 0.0
    # Avoid blindly adding entities from @pick_helper to selection.
    # It might be holding on to stale entity pointers. Since these tests erase
    # all entities per test it would be easy to feed the selection deleted
    # data. For instance when we test failure cases, PickHelper raises an error
    # before it get to reset. It's known that one should not hold on to
    # PickHelper for too long. Trouble is that view.pick_helper will return a
    # cached PickHelper. One should make sure to check the result value of a
    # pick before attempting to use it's entities.
    #Sketchup.active_model.selection.clear
    #Sketchup.active_model.selection.add(@pick_helper.all_picked)
    @pick_helper = nil
    if DEBUG_OUTPUT
      puts 'Teardown'
      entities = Sketchup.active_model.entities.to_a
      selection = Sketchup.active_model.selection.to_a
      diff = (selection - entities)

      puts "> Entities: #{entities.inspect}"
      puts "> Selection: #{selection.inspect}"
      puts "> Diff: #{diff.inspect}"
      puts "> Parent: #{diff.map { |i| i.parent }.inspect}"
      puts "> All Picked Size: #{@pick_helper.all_picked.size}"
      puts "> All Picked: #{@pick_helper.all_picked.inspect}"
    end
  end

  def setup_camera
    eye = [50,-50,100]
    target = [50,0,0]
    up = [0,1,0]
    camera = Sketchup.active_model.active_view.camera
    camera.set(eye, target, up)
    camera.aspect_ratio = 1.0
  end

  def add_window_pick_data
    model = Sketchup.active_model
    entities = model.active_entities
    model.start_operation('test', true) if block_given?
    # Put some stuff in the model
    entities = Sketchup.active_model.active_entities
    entities.add_face([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    entities.add_edges([1,1,1], [2,2,2])
    if block_given?
      model.commit_operation
      yield
#      model.abort_operation
    end
  end

  def add_boundingbox
    @boundingbox = Geom::BoundingBox.new
    @boundingbox.add([-10, -10, -10], [10, 10, 10])
  end

  def add_inside_edges
    model = Sketchup.active_model
    entities = model.active_entities
    model.start_operation('test', true) if block_given?
    entities.add_edges([1, 0, 0], [2, 0, 0])
    entities.add_edges([0, 5, 0], [0, 6, 0])
    model.commit_operation
    @num_inside_edges = 2
    if block_given?
      model.commit_operation
      yield
#      model.abort_operation
    end
  end

  def add_crossing_edges
    model = Sketchup.active_model
    entities = model.active_entities
    model.start_operation('test', true) if block_given?
    entities.add_edges([9, 0, 0], [11, 0, 0])
    entities.add_edges([0, 9, 0], [0, 11, 0])
    entities.add_edges([0, 0, 9], [0, 0, 11])
    model.commit_operation
    @num_crossing_edges = 3
    if block_given?
      model.commit_operation
      yield
#      model.abort_operation
    end
  end

  def add_outside_edges
    model = Sketchup.active_model
    entities = model.active_entities
    model.start_operation('test', true) if block_given?
    entities.add_edges([11, 0, 0], [13, 0, 0])
    entities.add_edges([0, 11, 0], [0, 13, 0])
    entities.add_edges([0, 0, 11], [0, 0, 13])
    entities.add_edges([-11, 0, 0], [-13, 0, 0])
    entities.add_edges([0, -11, 0], [0, -13, 0])
    entities.add_edges([0, 0, -11], [0, 0, -13])
    if block_given?
      model.commit_operation
      yield
#      model.abort_operation
    end
  end

  def add_inside_group
    # Inside group
    model = Sketchup.active_model
    group = model.entities.add_group
    entities = group.entities
    model.start_operation('test', true) if block_given?
    entities.add_face([1,1,2], [5,1,2], [5,5,2], [1,5,2])
    if block_given?
      model.commit_operation
      yield group
#      model.abort_operation
    else
      group
    end
  end

  def add_crossing_group
    model = Sketchup.active_model
    entities = model.active_entities
    model.start_operation('test', true) if block_given?
    group = model.entities.add_group
    entities = group.entities
    entities.add_face([1,1,5], [5,1,5], [5,5,5], [1,5,5])
    entities.add_face([6,6,5], [12,6,5], [12,12,5], [6,12,5])
    if block_given?
      model.commit_operation
      yield group
#      model.abort_operation
    else
      group
    end
  end


  # ========================================================================== #
  # method Sketchup::PickHelper.window_pick
  # http://www.sketchup.com/intl/developer/docs/ourdoc/pickhelper#window_pick

  def test_window_pick_api_example
    entities = Sketchup.active_model.active_entities
    face = entities.add_face([0,0,0], [100,0,0], [100,100,0], [0,100,0])
    ph = Sketchup.active_model.active_view.pick_helper
    start_point = Geom::Point3d.new(100, 100, 0)
    end_point = Geom::Point3d.new(500, 500, 0)
    num_picked = ph.window_pick start_point, end_point, Sketchup::PickHelper::PICK_CROSSING
  end

  def test_window_pick_same_point_values
    dup_point = Geom::Point3d.new(START_POINT.x, START_POINT.y, 0)
    generic_window_pick_test(START_POINT, dup_point, Sketchup::PickHelper::PICK_CROSSING, 0)
  end

  def test_window_pick_same_points
    generic_window_pick_test(START_POINT, START_POINT, Sketchup::PickHelper::PICK_CROSSING, 0)
  end

  def test_window_pick_negative_values_inside
    generic_window_pick_test(NEGATIVE_POINT, END_POINT, Sketchup::PickHelper::PICK_INSIDE, 1)
  end

  def test_window_pick_negative_values_crossing
    generic_window_pick_test(NEGATIVE_POINT, END_POINT, Sketchup::PickHelper::PICK_CROSSING, 4)
  end

  def test_window_pick_huge_points_inside
    generic_window_pick_test(START_POINT, FAR_POINT, Sketchup::PickHelper::PICK_INSIDE, 2)
  end

  def test_window_pick_huge_points_crossing
    generic_window_pick_test(START_POINT, FAR_POINT, Sketchup::PickHelper::PICK_CROSSING, 5)
  end

  def test_window_pick_none_inside
    generic_window_pick_test(ORIGIN_POINT, NEAR_POINT, Sketchup::PickHelper::PICK_INSIDE, 0)
  end

  def test_window_pick_none_crossing
    generic_window_pick_test(ORIGIN_POINT, NEAR_POINT, Sketchup::PickHelper::PICK_CROSSING, 0)
  end

  def test_window_pick_some_inside
    generic_window_pick_test(START_POINT, END_POINT, Sketchup::PickHelper::PICK_INSIDE, 1)
  end

  def test_window_pick_some_crossing
    generic_window_pick_test(START_POINT, END_POINT, Sketchup::PickHelper::PICK_CROSSING, 4)
  end

  def test_window_pick_reverse_points_inside
    generic_window_pick_test(END_POINT, START_POINT, Sketchup::PickHelper::PICK_INSIDE, 1)
  end

  def test_window_pick_reverse_points_crossing
    generic_window_pick_test(END_POINT, START_POINT, Sketchup::PickHelper::PICK_CROSSING, 4)
  end

  def test_window_pick_with_z_gt_1_inside
    generic_window_pick_test(Z_POINT, END_POINT, Sketchup::PickHelper::PICK_INSIDE, 1)
  end

  def test_window_pick_with_z_gt_1_crossing
    generic_window_pick_test(Z_POINT, END_POINT, Sketchup::PickHelper::PICK_CROSSING, 4)
  end

  def test_window_pick_inside_on_crossing_group
    add_crossing_group do |group|
      # We want to make a pick selection crossing the entity so we use the screen
      # projection of the center.
      center2d = group.model.active_view.screen_coords(group.bounds.center)
      end_point = Geom::Point3d.new(300, center2d.y, 0)

      num_picked = @pick_helper.window_pick(ORIGIN_POINT, end_point, Sketchup::PickHelper::PICK_INSIDE)
      assert_equal(0, num_picked)
      assert_equal(0, @pick_helper.all_picked.count)
    end
  end

  def generic_window_pick_test(point1, point2, pick_method, expected_count)
    add_window_pick_data do
      pick_helper = Sketchup.active_model.active_view.pick_helper
      num_picked = pick_helper.window_pick(point1, point2, pick_method)
      assert_equal(expected_count, num_picked)
      assert_equal(expected_count, pick_helper.all_picked.count)
    end
  end

  def test_window_pick_with_group
    add_window_pick_data do
      group = Sketchup.active_model.entities.add_group
      entities = group.entities
      face = entities.add_face([20,0,10], [30,0,10], [30,10,10], [20,10,10])

      generic_window_pick_test(START_POINT, END_POINT, Sketchup::PickHelper::PICK_CROSSING, 5)
      assert_kind_of(Sketchup::Group, @pick_helper.all_picked()[4])
    end
  end

  # ========================================================================== #
  # method Sketchup::PickHelper.boundingbox_pick
  # http://www.sketchup.com/intl/developer/docs/ourdoc/pickhelper#boundingbox_pick
  def test_boundingbox_pick_api_example
     boundingbox = Geom::BoundingBox.new
     boundingbox.add([1, 1, 1], [100, 100, 100])
     ph = Sketchup.active_model.active_view.pick_helper

     # Rotate the box 45' around the z-axis
     angle = 45
     transformation = Geom::Transformation.new(ORIGIN, Z_AXIS, angle)

     num_picked = ph.boundingbox_pick(boundingbox, Sketchup::PickHelper::PICK_CROSSING, transformation)
     if num_picked > 0
       Sketchup.active_model.selection.add(ph.all_picked)
     end
   end

  def test_boundingbox_pick_inside
    add_boundingbox
    add_inside_edges do
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_INSIDE)
      assert_equal(@num_inside_edges, num_picked)
      add_crossing_edges
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_INSIDE)
      assert_equal(@num_inside_edges, num_picked)
      add_outside_edges
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_INSIDE)
      assert_equal(@num_inside_edges, num_picked)
    end
  end

  def test_boundingbox_pick_crossing
    add_boundingbox
    add_crossing_edges do
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_CROSSING)
      assert_equal(@num_crossing_edges, num_picked)
      add_inside_edges
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_CROSSING)
      assert_equal(@num_crossing_edges + @num_inside_edges, num_picked)
      add_outside_edges
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_CROSSING)
      assert_equal(@num_crossing_edges + @num_inside_edges, num_picked)
    end
  end

  def test_boundingbox_pick_group_inside
    add_boundingbox
    add_inside_group do
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_INSIDE)
      assert_equal(1, num_picked)
      add_crossing_group
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_INSIDE)
      assert_equal(1, num_picked)
      add_crossing_edges
      add_outside_edges
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_INSIDE)
      assert_equal(1, num_picked)
    end
  end

  def test_boundingbox_pick_group_crossing
    add_boundingbox
    add_crossing_group do
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_CROSSING)
      assert_equal(1, num_picked)
      add_inside_group
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_CROSSING)
      assert_equal(2, num_picked)
      add_outside_edges
      assert_equal(2, num_picked)
    end
  end

  def test_boundingbox_pick_rotated_box
    add_boundingbox
    add_outside_edges do
      # Rotate the box 45' around the z-axis
      pt = Geom::Point3d.new(0,0,0)
      axis = vector = Geom::Vector3d.new(0,0,1)
      angle = 45
      transformation = Geom::Transformation.new(pt, axis, angle)
      # This should get the outside edges on the x/y plane
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, Sketchup::PickHelper::PICK_CROSSING, transformation)
      assert_equal(4, num_picked)
    end
  end

  def test_boundingbox_pick_invalid_boundingbox
    num_picked = 0
    assert_raises(TypeError) do
      num_picked = @pick_helper.boundingbox_pick('', 999)
    end
    assert_equal(0, num_picked)
  end

  def test_boundingbox_pick_invalid_pick_type
    add_boundingbox
    num_picked = 0
    assert_raises(ArgumentError) do
      num_picked = @pick_helper.boundingbox_pick(@boundingbox, 999)
    end
    assert_equal(0, num_picked)
  end

  def test_boundingbox_pick_too_few_arguments
    add_boundingbox
    num_picked = 0
    assert_raises(ArgumentError) do
      num_picked = @pick_helper.boundingbox_pick(@boundingbox)
    end
    assert_equal(0, num_picked)
  end

end # class
