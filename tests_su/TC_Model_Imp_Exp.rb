# frozen_string_literal: true

# SUMT.run %w[TC_Model_Imp_Exp.rb]

#———————————————————————————————————————————————————————————————————————————————
# Copyright:: Copyright 2014 Trimble Inc. All rights reserved.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen
#———————————————————————————————————————————————————————————————————————————————

# class Sketchup::Model
# http://www.sketchup.com/intl/developer/docs/ourdoc/model


class TC_Model_Imp_Exp < SUMT::TestCase

  TEMP_DIR = temp_dir

  def self.ste_teardown
    model = Sketchup.active_model
    model.respond_to?(:close) and model.close(true)
  end
  
  def setup
    start_with_empty_model
    @model = Sketchup.active_model
    @model.start_operation("SUMT - TC_Model", true)
    @model.select_tool(nil)
  end

  def teardown
    # Just to make sure no tests leave open Ruby transactions.
    Sketchup.active_model.abort_operation
  end

  def setup_with_jinyi_component
    start_with_empty_model
    import_file = get_test_file("jinyi.skp")
    assert_kind_of TrueClass, @model.import(import_file)
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

  def test_import_legacy_parameters
    start_with_empty_model
    dae_file = get_test_file("jinyi.dae")
    assert_kind_of TrueClass, @model.import(dae_file, false)
    definition_list = @model.definitions
    assert_equal(3, definition_list.count)
    assert_equal(622, definition_list.at(0).entities.count)
  end

  def test_import_dae_options
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.dae")
    options = { :validate_dae => true, 
                :merge_coplaner_faces => true,
                :show_summary => false}
    assert_kind_of TrueClass, @model.import(import_file, options)
    definition_list = @model.definitions
    assert_equal(3, definition_list.count)
    assert_equal(622, definition_list.at(0).entities.count)
  end

  def test_import_3ds_options
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.3ds")
    options = { :merge_coplaner_faces => true,
                :units => "mile",
                :show_summary => false}
    assert_kind_of TrueClass, @model.import(import_file, options)
    definition_list = @model.definitions
    assert_equal(5, definition_list.count)
    assert_equal(38, definition_list.at(0).entities.count)
  end

  def test_import_dwg_options
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.dwg")
    options = { :merge_coplaner_faces => true,
                :orient_faces => true,
                :preserve_origin => true,
                :show_summary => false}
    assert_kind_of TrueClass, @model.import(import_file, options)
    definition_list = @model.definitions
    assert_equal(3, definition_list.count)
    assert_equal(169, definition_list.at(0).entities.count)
  end

  def test_import_dxf_options
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.dxf")
    options = { :merge_coplaner_faces => false,
                :orient_faces => true,
                :preserve_origin => true,
                :show_summary => false}
    assert_kind_of TrueClass, @model.import(import_file, options)
    definition_list = @model.definitions
    assert_equal(3, definition_list.count)
    assert_equal(264, definition_list.at(0).entities.count)
  end

  def test_import_ifc_options
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.ifc")
    assert_kind_of TrueClass, @model.import(import_file, false)
    definition_list = @model.definitions
    assert_equal(6, definition_list.count)
    assert_equal(821, definition_list.at(0).entities.count)
  end

  def test_import_kmz_options
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.kmz")
    options = { :validate_kmz => true,
                :merge_coplaner_faces => true,
                :show_summary => false}
    assert_kind_of TrueClass, @model.import(import_file, options)
    definition_list = @model.definitions
    assert_equal(2, definition_list.count)
    assert_equal(299, definition_list.at(0).entities.count)
  end

  def test_import_stl_options
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    start_with_empty_model
    import_file = get_test_file("jinyi.stl")
    options = { :units => "inch",
                :merge_coplaner_faces => false,
                :preserve_origin => true,
                :swap_yz => true}
    assert_kind_of TrueClass, @model.import(import_file, options)
    definition_list = @model.definitions
    assert_equal(1, definition_list.count)
    assert_equal(820, definition_list.at(0).entities.count)
  end

  def test_export_3ds_otions
    export_file = "#{TEMP_DIR}/jinyi.3ds"
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    setup_with_jinyi_component
    options = { :units => "m",
                :geometry => "by_material",
                :doubledsided_faces => true,
                :faces => "not_two_sided",
                :edges => true,
                :texture_maps => true,
                :preserve_texture_coords => true,
                :cameras => true,
                :show_summary => false}
    assert_kind_of TrueClass, @model.export(export_file, options)
    assert(File.exist?(export_file) && File.size(export_file) > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_dae_options
    export_file = "#{TEMP_DIR}/jinyi.dae"
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    setup_with_jinyi_component
    options = { :triangulated_faces => true,
                :doublesided_faces => true,
                :edges => true,
                :author_attribution => true,
                :hidden_geomtry => true,
                :preserve_instancing => true,
                :texture_maps => true,
                :selectionset_only => true,
                :show_summary => false}
    assert_kind_of TrueClass, @model.export(export_file, options)
    assert(File.exist?(export_file) && File.size(export_file) > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_dwg_options
    export_file = "#{TEMP_DIR}/jinyi.dwg"
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    setup_with_jinyi_component
    
    options = { :acad_version => "acad_2013",
                :faces_flag => true,
                :construction_geometry => true,
                :dimensions => true,
                :text => true,
                :edges => true,
                :show_summary => false}
    assert_kind_of TrueClass, @model.export(export_file, options)
    assert(File.exist?(export_file) && File.size(export_file) > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_dxf_options
    export_file = "#{TEMP_DIR}/jinyi.dxf"
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    setup_with_jinyi_component

    options = { :acad_version => "acad_2013",
                :faces_flag => true,
                :construction_geometry => true,
                :dimensions => true,
                :text => true,
                :edges => true,
                :show_summary => false}
    assert_kind_of TrueClass, @model.export(export_file, options)
    assert(File.exist?(export_file) && File.size(export_file) > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_fbx_options
    export_file = "#{TEMP_DIR}/jinyi.fbx"
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    setup_with_jinyi_component

    options = { :units => "mile",
                :triangulated_faces => true,
                :doublesided_faces => true,
                :texture_maps => true,
                :separate_disconnected_faces => true,
                :swap_yz => true,
                :show_summary => false}
    assert_kind_of TrueClass, @model.export(export_file, options)
    assert(File.exist?(export_file) && File.size(export_file) > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_ifc_options
    export_file = "#{TEMP_DIR}/jinyi.ifc"
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    setup_with_jinyi_component

    options = { :hidden_geometry => true,
                :doublesided_faces => true,
                :ifc_mapped_items => true,
                :ifc_types => [
                  "IfcBeam",
                  "IfcBuilding",
                  "IfcBuildingElementProxy",
                  "IfcBuildingStorey",
                  "IfcColumn",
                  "IfcCurtainWall",
                  "IfcDoor",
                  "IfcFooting",
                  "IfcFurnishingElement",
                  "IfcMember",
                  "IfcPile",
                  "IfcPlate",
                  "IfcProject",
                  "IfcRailing",
                  "IfcRamp",
                  "IfcRampFlight",
                  "IfcRoof",
                  "IfcSite",
                  "IfcSlab",
                  "IfcSpace",
                  "IfcStair",
                  "IfcStairFlight",
                  "IfcWall",
                  "IfcWallStandardCase",
                  "IfcWindow"],
                :show_summary => false}
    assert_kind_of TrueClass, @model.export(export_file, options)
    assert(File.exist?(export_file) && File.size(export_file) > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_kmz_options
    export_file = "#{TEMP_DIR}/jinyi.kmz"
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    setup_with_jinyi_component

    options = { :author_attribution => true,
                :hidden_geometry => true,
                :show_summary => true}
    assert_kind_of TrueClass, @model.export(export_file, options)
    assert(File.exist?(export_file) && File.size(export_file) > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_obj_options
    export_file = "#{TEMP_DIR}/jinyi.obj"
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    setup_with_jinyi_component

    options = { :units => "model",
                :triangulated_faces => true,
                :doublesided_faces => true,
                :edges => true,
                :texture_maps => true,
                :swap_yz => true,
                :show_summary => false}
    assert_kind_of TrueClass, @model.export(export_file, options)
    assert(File.exist?(export_file) && File.size(export_file) > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_xsi_options
    export_file = "#{TEMP_DIR}/jinyi.xsi"
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    setup_with_jinyi_component

    options = { :units => "model",
                :triangulated_faces => true,
                :doublesided_faces => true,
                :edges => true,
                :texture_maps => true,
                :swap_yz => true,
                :show_summary => false}
    assert_kind_of TrueClass, @model.export(export_file, options)
    assert(File.exist?(export_file) && File.size(export_file) > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_wrl_options
    export_file = "#{TEMP_DIR}/jinyi.wrl"
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    setup_with_jinyi_component

    options = { :doublesided_faces => true,
                :cameras => true,
                :use_vrml_orientation => true,
                :edges => true,
                :texture_maps => true,
                :allow_mirrored_componenets => true,
                :material_overrides => true,
                :show_summary => false}
    assert_kind_of TrueClass, @model.export(export_file, options)
    assert(File.exist?(export_file) && File.size(export_file) > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end

  def test_export_stl_options
    export_file = "#{TEMP_DIR}/jinyi.stl"
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    setup_with_jinyi_component

    options = { :units => "model",
                :format => "ascii",
                :selectionset_only => true,
                :swap_yz => true,
                :show_summary => false}
    assert_kind_of TrueClass, @model.export(export_file, options)
    assert(File.exist?(export_file) && File.size(export_file) > 0)
  ensure
    File.delete(export_file) if File.exist?(export_file)
  end


end # class
