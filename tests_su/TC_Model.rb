# frozen_string_literal: true

# SUMT.run %w[TC_Model.rb]

#———————————————————————————————————————————————————————————————————————————————
# Copyright:: Copyright 2014 Trimble Inc. All rights reserved.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen
#———————————————————————————————————————————————————————————————————————————————

# class Sketchup::Model
# http://www.sketchup.com/intl/developer/docs/ourdoc/model
class TC_Model < SUMT::TestCase

  TEMP_DIR = temp_dir

  def setup
    start_with_empty_model
    @model = Sketchup.active_model
    @model.start_operation("SUMT - TC_Model", true)
    create_test_tube unless self.name =~ /\Atest_(import|export)/
    @model.select_tool(nil)
  end

  def teardown
    # Just to make sure no tests leave open Ruby transactions.
    Sketchup.active_model.abort_operation
  end

  def add_extra_groups_and_components
    entities = @model.active_entities
#    @model.start_operation("SUMT - Test Groups", true)
    10.times { |i|
      group = entities.add_group
      group.entities.add_face([0,0,i], [9,0,i], [9,9,i], [0,9,i])
    }
    definition = @model.definitions.add("SUMT")
    definition.entities.add_face([0,0,0], [9,0,0], [9,9,0], [0,9,0])
    10.times { |i|
      origin = ORIGIN.offset(X_AXIS, i * 10)
      tr = Geom::Transformation.new(origin)
      entities.add_instance(definition, tr)
    }
#    @model.commit_operation
    nil
  end

  def create_test_tube
    entities = @model.active_entities
    group = entities.add_group
    circle = group.entities.add_circle(ORIGIN, Z_AXIS, 10, 8)
    circle[0].find_faces
    face = group.entities.grep(Sketchup::Face)[0]
    face.pushpull(-50)
    nil
  end

  def get_model_entities
    entities = []
    @model.entities.each { |instance|
      entities << instance
      if instance.is_a?(Sketchup::Group)
        entities.concat(instance.entities.to_a)
      else
        entities.concat(instance.definition.entities.to_a)
      end
    }
    entities
  end


  # ========================================================================== #
  # method Sketchup::Model.start_operation
  # http://www.sketchup.com/intl/developer/docs/ourdoc/model#start_operation

  def test_start_operation_warn_new_nested_operation
    original_mode = Sketchup.debug_mode?
    skip("Implemented in SU2016") if SU_VERS_INT < 16
    Sketchup.debug_mode = true
    
    stderr = capture_stderr(VERBOSE_SOME) { @model.start_operation("World") }
    expected_warning = %{warning: New operation ("World") started while an existing operation ("SUMT - TC_Model") was still open}
    assert stderr.include?(expected_warning),
      "Expected warning: #{expected_warning}\nResult: #{stderr}"
  ensure
    Sketchup.debug_mode = original_mode
  end


  # ========================================================================== #
  # method Sketchup::Model.close
  # http://www.sketchup.com/intl/developer/docs/ourdoc/model#close

  def test_close_api_example
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    discard_model_changes()
    # API example starts here:
    Sketchup.file_new
    model = Sketchup.active_model
    model.close
  end

  def test_close_invalid_args
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    discard_model_changes()
    # The first boolean argument can really be anything since anything converts
    # to bool in Ruby. But test too many args
    Sketchup.file_new
    assert_raises(ArgumentError, "Too many arguments") do
      Sketchup.active_model.close(true, "")
    end
  end

  def test_close
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    discard_model_changes()
    m0 = Sketchup.active_model
    Sketchup.file_new
    m1 = Sketchup.active_model
    Sketchup.file_new
    m2 = Sketchup.active_model

    m2.close
    assert_equal(m1, Sketchup.active_model)
    m1.close
    assert_equal(m0, Sketchup.active_model)
  end

  def test_close_inactive_model
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    discard_model_changes
    # Inapplicable to Windows since there is one document
    skip("Not relevant for Windows") if Sketchup.platform == :platform_win

    Sketchup.file_new
    m0 = Sketchup.active_model
    Sketchup.file_new
    m1 = Sketchup.active_model

    assert_raises(RuntimeError, "Closed inactive model") do
      m0.close
    end

    # Close them in proper order
    m1.close
    m0.close
  end

  # ========================================================================== #
  # method Sketchup::Model.find_entity_by_id
  # http://www.sketchup.com/intl/developer/docs/ourdoc/model#find_entity_by_id

  def test_find_entity_by_id_api_example
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    # Init dummy variables to avoid raising errors.
    id1 = id2 = id3 = 0
    guid1 = guid2 = guid3 = ""

    model = Sketchup.active_model
    # Look up by entityID.
    entity_id = model.entities.add_line([0,0,0], [9,9,9]).entityID
    entity = model.find_entity_by_id(entity_id)
    # Look up by GUID.
    guid = model.entities.add_group.guid
    entity = model.find_entity_by_id(guid)
    # Look up multiple.
    entities = model.find_entity_by_id(id1, id2, id3)
    entities = model.find_entity_by_id([id1, id2, id3])
    entities = model.find_entity_by_id(guid1, guid2, guid3)
    entities = model.find_entity_by_id([guid1, guid2, guid3])
  end

  def test_find_entity_by_id_entity_id
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    group = @model.entities[0]
    entity = group.entities[0]

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_array_single_item
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    group = @model.entities[0]
    entity = group.entities[0]

    result = @model.find_entity_by_id([entity.entityID])
    assert_equal([entity], result)
  end

  def test_find_entity_by_id_entity_id_array
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    add_extra_groups_and_components()

    entities = get_model_entities()
    ids = entities.map { |entity| entity.entityID }

    result = @model.find_entity_by_id(ids)
    assert_equal(entities.size, result.size)
    assert_equal(entities, result)
  end

  def test_find_entity_by_id_guid
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    group = @model.entities[0]

    add_extra_groups_and_components()

    result = @model.find_entity_by_id(group.guid)
    assert_equal(group, result)
  end

  def test_find_entity_by_id_guids
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    add_extra_groups_and_components()

    entities = @model.entities.to_a
    guids = entities.map { |instance| instance.guid }

    result = @model.find_entity_by_id(guids)
    assert_equal(entities, result)
  end

  def test_find_entity_by_id_not_found
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    assert_nil @model.find_entity_by_id(-123)
  end

  def test_find_entity_by_id_not_found_array
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    result = @model.find_entity_by_id([-1, -2, -3])
    assert_equal([nil, nil, nil], result)
  end

  def test_find_entity_by_id_mixed_search_result_entity_id
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    group = @model.entities[0]
    result = @model.find_entity_by_id([-1, group.entityID, -3])
    assert_equal([nil, group, nil], result)
  end

  def test_find_entity_by_id_mixed_search_result_guid
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    group = @model.entities[0]
    add_extra_groups_and_components()
    result = @model.find_entity_by_id(["", group.guid, ""])
    assert_equal([nil, group, nil], result)
  end

  def test_find_entity_by_id_guid_multiple_identical
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    group = @model.entities[0]

    add_extra_groups_and_components()

    guids = [group.guid] * 3
    expected = [group] * 3
    assert_equal expected, @model.find_entity_by_id(guids)
  end

  def test_find_entity_by_id_entity_id_edge
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    entity = @model.entities.add_line([0,0,0], [9,9,9])
    assert_equal entity, @model.find_entity_by_id(entity.entityID)
  end

  def test_find_entity_by_id_entity_id_face
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    entity = @model.entities.add_face([0,0,0], [9,0,0], [9,9,0])
    assert_equal entity, @model.find_entity_by_id(entity.entityID)
  end

  def test_find_entity_by_id_entity_id_group
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    entity = @model.entities.add_group
    assert_equal entity, @model.find_entity_by_id(entity.entityID)
  end

  def test_find_entity_by_id_entity_id_component_instance
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    add_extra_groups_and_components()
    entity = @model.entities.grep(Sketchup::ComponentInstance)[0]
    assert_equal entity, @model.find_entity_by_id(entity.entityID)
  end

  def test_find_entity_by_id_entity_id_image
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    filename = get_test_file "test.jpg"
    entity = @model.entities.add_image(filename, ORIGIN, 1.m)
    assert_equal entity, @model.find_entity_by_id(entity.entityID)
  end

  def test_find_entity_by_id_entity_id_cpoint
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    entity = @model.entities.add_cpoint(ORIGIN)
    assert_equal entity, @model.find_entity_by_id(entity.entityID)
  end

  def test_find_entity_by_id_entity_id_cline
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    entity = @model.entities.add_cline(ORIGIN, [9,0,0])
    assert_equal entity, @model.find_entity_by_id(entity.entityID)
  end

  def test_find_entity_by_id_entity_id_dimension_linear
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    entity = @model.entities.add_dimension_linear(
      [50, 10, 0], [100, 10, 0], [0, 20, 0])
    assert_equal entity, @model.find_entity_by_id(entity.entityID)
  end

  def test_find_entity_by_id_entity_id_dimension_radial
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    centerpoint = Geom::Point3d.new(10, 10, 0)
    vector = Geom::Vector3d.new(0, 0, 1)
    edges = @model.entities.add_circle(centerpoint, vector, 10)
    circle = edges[0].curve
    entity = @model.entities.add_dimension_radial(
      circle, [30, 30, 0])

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_section_plane
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    entity = @model.entities.add_section_plane(
      [50, 50, 0], [1.0, 1.0, 0])

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_text
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    entity = @model.entities.add_text("This is a Test", ORIGIN)

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_vertex
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    entity = @model.entities.add_line([0,0,0], [9,9,9]).start

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_component_definition
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    entity = @model.entities[0].entities.parent

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_definition_list
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    skip("DefinitionList objects not supported")
    entity = @model.definitions

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_arc_curve
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    edges = @model.entities.add_circle(ORIGIN, Z_AXIS, 1.m)
    entity = edges[0].curve

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_curve
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    edges = @model.entities.add_curve([0,0,0], [0,9,0], [1,9,0])
    entity = edges[0].curve

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_layers
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    skip("Layers objects not supported")
    entity = @model.layers

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_layer
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    entity = @model.active_layer

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_materials
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    skip("Materials objects not supported")
    entity = @model.materials

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_material
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    entity = @model.materials.add("SUMT")

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_pages
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    skip("Pages objects not supported")
    entity = @model.pages

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_page
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    @model.pages.add("SUMT")
    entity = @model.pages[0]

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_attribute_dictionaries
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    skip("AttributeDictionaries objects not supported")
    @model.set_attribute("SUMT", "Hello", "World")
    entity = @model.attribute_dictionaries

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_attribute_dictionary
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    skip("AttributeDictionary objects not supported")
    entity = @model.attribute_dictionary("SUMT", true)

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_edgeuse
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    skip("EdgeUse objects not supported")
    face = @model.entities.add_face([0,0,0], [9,0,0], [9,9,0])
    entity = face.outer_loop.edgeuses[0]

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_loop
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    skip("Loop objects not supported")
    face = @model.entities.add_face([0,0,0], [9,0,0], [9,9,0])
    entity = face.outer_loop

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_rendering_options
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    skip("RenderingOptions objects not supported")
    entity = @model.rendering_options

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_shadow_info
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    skip("ShadowInfo objects not supported")
    entity = @model.shadow_info

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_styles
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    skip("Styles objects not supported")
    entity = @model.styles

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_style
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    entity = @model.styles.selected_style

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_entity_id_texture
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    @model.entities.clear!
    filename = get_test_file "test.jpg"
    image = @model.entities.add_image(filename, ORIGIN, 1.m)
    image.explode
    face = @model.entities.grep(Sketchup::Face)[0]
    entity = face.material.texture

    result = @model.find_entity_by_id(entity.entityID)
    assert_equal(entity, result)
  end

  def test_find_entity_by_id_invalid_arguments
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    assert_raises(TypeError, "Argument with nil") do
      @model.find_entity_by_id(nil)
    end

    assert_raises(TypeError, "Argument with Point3d") do
      @model.find_entity_by_id(ORIGIN)
    end
  end

  def test_find_entity_by_id_invalid_arguments_mixed_with_valid
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    assert_raises(TypeError, "Argument with nil") do
      @model.find_entity_by_id(123, nil)
    end

    assert_raises(TypeError, "Argument with Point3d") do
      @model.find_entity_by_id(123, ORIGIN)
    end
  end

  def test_find_entity_by_id_invalid_array_arguments_mixed_with_valid
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    assert_raises(TypeError, "Argument with nil") do
      @model.find_entity_by_id([123, nil])
    end

    assert_raises(TypeError, "Argument with Point3d") do
      @model.find_entity_by_id([123, ORIGIN])
    end
  end

  def test_find_entity_by_id_invalid_arguments_entity_id_with_guid
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    assert_raises(TypeError, "Array of EntityID with String") do
      @model.find_entity_by_id(123, "FooBar")
    end
  end

  def test_find_entity_by_id_invalid_arguments_guid_with_entity_id
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    assert_raises(TypeError, "Array of GUID with EntityID") do
      @model.find_entity_by_id("FooBar", 123)
    end
  end

  def test_find_entity_by_id_incorrect_number_of_arguments
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    assert_raises(ArgumentError, "No arguments") do
      @model.find_entity_by_id()
    end
  end

  def test_find_entity_by_id_invalid_empty_array_arguments
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    assert_raises(ArgumentError, "Empty array") do
      @model.find_entity_by_id([])
    end
  end


  # ========================================================================== #
  # method Sketchup::Model.find_entity_by_persistent_id

  def test_find_entity_by_persistent_id_api_example
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    model = Sketchup.active_model
    # Init dummy variables to avoid raising errors.
    id1 = id2 = id3 = 0
    # Example Start:

    # Look up by persistent_id.
    pid = model.entities.add_line([0,0,0], [9,9,9]).persistent_id
    entity = model.find_entity_by_persistent_id(pid)
 
    # Look up multiple.
    entities = model.find_entity_by_persistent_id(id1, id2, id3)
    entities = model.find_entity_by_persistent_id([id1, id2, id3])
  end

  def test_find_entity_by_persistent_id_entity_id
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    group = @model.entities[0]
    entity = group.entities[0]

    result = @model.find_entity_by_persistent_id(
        entity.persistent_id)
    assert_equal(entity, result)
  end

  def test_find_entity_by_persistent_id_entity_id_array_single_item
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    group = @model.entities[0]
    entity = group.entities[0]

    result = @model.find_entity_by_persistent_id(
        [entity.persistent_id])
    assert_equal([entity], result)
  end

  def test_find_entity_by_persistent_id_entity_id_array
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    add_extra_groups_and_components()

    entities = get_model_entities()
    ids = entities.map { |entity| entity.persistent_id }

    result = @model.find_entity_by_persistent_id(ids)
    assert_equal(entities.size, result.size)
    assert_equal(entities, result)
  end

  def test_find_entity_by_persistent_id_entity_id_multiple_arguments
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    add_extra_groups_and_components()

    entities = get_model_entities()
    ids = entities.map { |entity| entity.persistent_id }

    result = @model.find_entity_by_persistent_id(*ids)
    assert_equal(entities.size, result.size)
    assert_equal(entities, result)
  end


  # ========================================================================== #
  # method Sketchup::Model.instance_path_from_pid_path

  def test_instance_path_from_pid_path_api_example
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    points = [
      Geom::Point3d.new( 0,  0, 0),
      Geom::Point3d.new(10,  0, 0),
      Geom::Point3d.new(10, 20, 0),
      Geom::Point3d.new( 0, 20, 0)
    ]
    model = Sketchup.active_model
    entities = model.active_entities
    group = entities.add_group
    face = group.entities.add_face(points)
    pid_path = "#{group.persistent_id}.#{face.persistent_id}"
    # pid_path will look something like this: "658.723"
    instance_path = model.instance_path_from_pid_path(pid_path)
  end

  def test_instance_path_from_pid_path
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    points = [
      Geom::Point3d.new( 0,  0, 0),
      Geom::Point3d.new(10,  0, 0),
      Geom::Point3d.new(10, 20, 0),
      Geom::Point3d.new( 0, 20, 0)
    ]
    entities = @model.active_entities
    group = entities.add_group
    face = group.entities.add_face(points)
    pid_path = "#{group.persistent_id}.#{face.persistent_id}"

    result = @model.instance_path_from_pid_path(pid_path)
    assert_kind_of(Sketchup::InstancePath, result)
    assert_equal([group, face], result.to_a)
  end

  def test_instance_path_from_pid_path_invalid_path_invalid_ids
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    assert_raises(ArgumentError) {
      instance_path = @model.instance_path_from_pid_path(-1, -2)
    }
  end

  def test_instance_path_from_pid_path_invalid_path
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    assert_raises(ArgumentError) {
      instance_path = @model.instance_path_from_pid_path(999998, 999999)
    }
  end

  def test_instance_path_from_pid_path_incorrect_number_of_arguments_zero
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    assert_raises(ArgumentError) {
      instance_path = @model.instance_path_from_pid_path
    }
  end

  def test_instance_path_from_pid_path_invalid_argument_nil
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    assert_raises(TypeError) {
      instance_path = @model.instance_path_from_pid_path(nil)
    }
  end

  def test_instance_path_from_pid_path_invalid_argument_string
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    assert_raises(ArgumentError) {
      instance_path = @model.instance_path_from_pid_path("hello")
    }
  end

  def test_instance_path_from_pid_path_incorrect_number_of_arguments_two
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    assert_raises(ArgumentError) {
      instance_path = @model.instance_path_from_pid_path(1, 2)
    }
  end


  # Class to use for tool tests
  class MyTool; end

  def test_select_tool
    mytool = MyTool.new
    @model.select_tool(mytool)
    assert_operator(@model.tools.active_tool_id, :>, 50000,
        "Tool ID was invalid")
  end

  def test_select_tool_default
    @model.select_tool(nil)
    # This magic number is the resource ID for the select tool (ID_DRAW_SELECT)
    assert_equal(21022, @model.tools.active_tool_id,
        "Tool stack was not cleared")
  end

  def test_select_tool_clear
    mytool = MyTool.new
    @model.select_tool mytool
    @model.select_tool(nil)
    assert_equal(21022, @model.tools.active_tool_id,
        "Tool stack was not cleared")
  end


  def test_select_tool_diff_tools
    mytool = MyTool.new
    @model.select_tool mytool
    mytool_id = @model.tools.active_tool_id

    # Add second tool instance and confirm the tool ID is different
    mytool2 = MyTool.new
    @model.select_tool mytool2
    refute_equal(@model.tools.active_tool_id, mytool_id,
        "Tool ID did not change")
  end

  def test_select_tool_same_tool_2x
    mytool = MyTool.new
    @model.select_tool mytool
    mytool_id = @model.tools.active_tool_id

    # Clear the tool stack
    @model.select_tool nil

    # Re-add the same tool and confirm the tool ID is different
    @model.select_tool mytool
    refute_equal(@model.tools.active_tool_id, mytool_id,
        "Tool ID did not change")
  end

end # class
