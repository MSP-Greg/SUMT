# Copyright:: Copyright 2016 Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen





class TC_InputPoint < SUMT::TestCase

  # Set this to true to enable verbose debugging output.
  DEBUG_OUTPUT = false

  def setup
    start_with_empty_model
    # TODO(thomthom):
    # Some test runs would fail without this. It is not known why, something
    # can get out of sync with the code the computes view.screen_coords.
    # Only particular order of tests would trigger this, and only upon the very
    # first run of this test. Otherwise it'll pass.
    # This is logged as SU-35668. This line can be removed once that issue
    # is resolved. For now its left in in order to reduce noise.
    view = Sketchup.active_model.active_view
    view.refresh
  end

  def teardown
  end


  # Model > ComponentInstance > Group1 > Group2 > Group3 > Edge
  def create_test_instances
    model = Sketchup.active_model
    model.start_operation('test', true)
    definition = model.definitions.add('TC_InputPoint')
    group1 = definition.entities.add_group
    group2 = group1.entities.add_group
    group2.transform!([10, 20, 30])
    group3 = group2.entities.add_group
    edge = group3.entities.add_line([10, 10, 10], [20, 20, 20])
    tr = Geom::Transformation.new([20, 30, 40])
    instance = model.entities.add_instance(definition, tr)
    path = [instance, group1, group2, group3, edge]
    yield path
    if path
      model.entities.erase_entities(path[0]) if path[0].valid?
      model.definitions.remove(definition) if Sketchup.version.to_i >= 18
      path.each { |e| e = nil }
      path = nil
    end
    model.definitions.purge_unused
    model.abort_operation
  end

  def compute_expected_transformation(path)
    instances = path.select { |entity|
      entity.is_a?(Sketchup::Group) || entity.is_a?(Sketchup::ComponentInstance)
    }
    tr = Geom::Transformation.new
    instances.each { |instance| tr = tr * instance.transformation }
    tr
  end

  def edge_mid_point(edge)
    pt1 = edge.start.position
    pt2 = edge.end.position
    Geom.linear_combination(0.5, pt1, 0.5, pt2)
  end


  # ========================================================================== #
  # class Sketchup::InputPoint

  def test_introduction_api_example
    # TODO:
  end


  # ========================================================================== #
  # method Sketchup::InputPoint.instance_path

  def test_instance_path
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    create_test_instances do |path|
      # Compute the screen coordinate of one of the entities in the path.
      view = Sketchup.active_model.active_view
      tr = compute_expected_transformation(path)
      local_point = edge_mid_point(path.last)
      point = local_point.transform(tr)
      screen_point = view.screen_coords(point)
      if DEBUG_OUTPUT
        puts 'TC_InputPoint#test_instance_path'
        puts ">   Num Entities: #{Sketchup.active_model.entities.size}"
        puts "> Transformation: #{tr.to_a}"
        puts ">  Local Edge Mid Point: #{local_point.inspect}"
        puts "> Global Edge Mid Point: #{point.inspect}"
        puts ">          Screen Point: #{screen_point.inspect}"
        puts ">              Viewport: #{view.vpwidth}x#{view.vpheight}"
        puts "> aspect_ratio: #{view.camera.aspect_ratio.inspect}"
        puts "> center_2d: #{view.camera.center_2d.inspect}"
        puts "> direction: #{view.camera.direction.inspect}"
        puts "> focal_length: #{view.camera.focal_length.inspect}"
        puts "> fov: #{view.camera.fov.inspect}"
        puts "> fov_is_height?: #{view.camera.fov_is_height?.inspect}"
        puts "> height: #{view.camera.height.inspect}"
        puts "> image_width: #{view.camera.image_width.inspect}"
        puts "> is_2d?: #{view.camera.is_2d?.inspect}"
        puts "> perspective?: #{view.camera.perspective?.inspect}"
        puts "> scale_2d: #{view.camera.scale_2d.inspect}"
        puts "> target: #{view.camera.target.inspect}"
        puts "> up: #{view.camera.up.inspect}"
        puts "> xaxis: #{view.camera.xaxis.inspect}"
        puts "> yaxis: #{view.camera.yaxis.inspect}"
        puts "> zaxis: #{view.camera.zaxis.inspect}"
      end
      # Make the instance point pick this entity.
      inputpoint = Sketchup::InputPoint.new
      changed = inputpoint.pick(view, screen_point.x, screen_point.y)
      assert(changed, 'InputPoint.pick did not indicate change')
      assert(inputpoint.valid?, 'InputPoint instance not valid')

      result = inputpoint.instance_path
      if DEBUG_OUTPUT
        puts ">      valid?: #{inputpoint.valid?}"
        puts ">        face: #{inputpoint.face}"
        puts ">        edge: #{inputpoint.edge}"
        puts ">      vertex: #{inputpoint.vertex}"
      end
      assert_kind_of(Sketchup::InstancePath, result)
      assert_equal(path, result.to_a)
    end
  end

  def test_instance_path_no_pick
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    inputpoint = Sketchup::InputPoint.new
    result = inputpoint.instance_path
    assert_nil(result)
  end

  def test_instance_path_incorrect_number_of_arguments_one
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17
    inputpoint = Sketchup::InputPoint.new
    assert_raises(ArgumentError) {
      inputpoint.instance_path(nil)
    }
  end

end # class
