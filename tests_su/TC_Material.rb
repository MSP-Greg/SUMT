# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen
#———————————————————————————————————————————————————————————————————————————————

# class Sketchup::Material
# http://www.sketchup.com/intl/developer/docs/ourdoc/material
class TC_Material < SUMT::TestCase

  TEST_MODEL = get_test_file "MaterialTests.skp"
  TEST_JPG   = get_test_file "Test.jpg"

  def self.ste_setup
    model = Sketchup.active_model
    model.respond_to?(:close) and model.close(true)
    FileUtils.chmod("a+w", TEST_MODEL)
    Sketchup.open_file(TEST_MODEL)
  end

  def setup
    @model = Sketchup.active_model
    @model.start_operation(self.name, true)
    @mats = @model.materials
  end

  def teardown
    @model.abort_operation
  end

  def open_test_model
    # To speed up tests the model is reused is possible. Tests that modify the
    # model should discard the model changes: close_active_model()
    # TODO(thomthom): Add a Ruby API method to expose the `dirty` state of the
    # model - whether it's been modified since last save/open.
    # Model.path must be converted to Ruby style path as SketchUp returns an
    # OS dependent path string.
    model = Sketchup.active_model
    if model.nil? || File.expand_path(model.path) != TEST_MODEL
      close_active_model()
      Sketchup.open_file(TEST_MODEL)
    end
    @model = Sketchup.active_model
    @mats = @model.materials
  end

  # ========================================================================== #
  # method Sketchup::Material.colorize_deltas
  # http://www.sketchup.com/intl/developer/docs/ourdoc/material#colorize_deltas

  def test_colorize_deltas_api_example
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats[0]
    h, l, s = material.colorize_deltas
  end

  def test_colorize_deltas_solid_material
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["Solid"]
    result = material.colorize_deltas
    assert_kind_of(Array, result)
    assert_equal(3, result.size)
    assert_kind_of(Float, result[0])
    assert_kind_of(Float, result[1])
    assert_kind_of(Float, result[2])
    assert_equal([0.0, 0.0, 0.0], result)
  end

  def test_colorize_deltas_textured_material
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["Textured"]
    result = material.colorize_deltas
    assert_kind_of(Array, result)
    assert_equal(3, result.size)
    assert_kind_of(Float, result[0])
    assert_kind_of(Float, result[1])
    assert_kind_of(Float, result[2])
    assert_equal([0.0, 0.0, 0.0], result)
  end

  def test_colorize_deltas_colorized_textured_material_shifted
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["TexturedShifted"]
    result = material.colorize_deltas
    assert_kind_of(Array, result)
    assert_equal(3, result.size)
    assert_kind_of(Float, result[0])
    assert_kind_of(Float, result[1])
    assert_kind_of(Float, result[2])
    assert_in_delta(-124.15384917569565,    result[0], SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(-0.0019607990980148315, result[1], SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta( 0.27996034147878235,   result[2], SKETCHUP_FLOAT_TOLERANCE)
  end

  def test_colorize_deltas_colorized_textured_material_tinted
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["TexturedTinted"]
    result = material.colorize_deltas
    assert_kind_of(Array, result)
    assert_equal(3, result.size)
    assert_kind_of(Float, result[0])
    assert_kind_of(Float, result[1])
    assert_kind_of(Float, result[2])
    assert_in_delta(38.04878252219892,     result[0], SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(0.0039215534925460815, result[1], SKETCHUP_FLOAT_TOLERANCE)
    assert_in_delta(0.3604408195287968,    result[2], SKETCHUP_FLOAT_TOLERANCE)
  end

  def test_colorize_deltas_incorrect_number_of_arguments_one
    material = @mats["Solid"]
    assert_raises(ArgumentError) { material.colorize_deltas nil }
  end

  # ========================================================================== #
  # method Sketchup::Material.name
  # http://www.sketchup.com/intl/developer/docs/ourdoc/material#name

  def test_name
    assert_equal("Textured", @mats[0].name)
    assert_equal("TexturedShifted", @mats[1].name)
  end

  def test_name_incorrect_number_of_arguments_one
    material = @mats["Solid"]
    assert_raises(ArgumentError) { material.name nil }
  end

  # ========================================================================== #
  # method Sketchup::Material.name=
  # http://www.sketchup.com/intl/developer/docs/ourdoc/material#name=

  def test_set_name
    test_mat = @mats.add("test_name")
    assert_equal("test_name", test_mat.name)
    test_mat.name = "test_name0"
    assert_equal("test_name0", test_mat.name)
    test_mat.name = "Textured0"
    assert_equal("Textured0", test_mat.name)
  end

  def test_set_name_duplicate_failure
    skip("Implemented in SU2018") if SU_VERS_INT < 18
    material = @mats["Solid"]
    assert_raises(ArgumentError) { material.name = "Textured" }
  end

  def test_set_name_reuse_old_name
    material = @mats.add('OriginalName')
    material.name = "NewUnusedName"
    material.name = "OriginalName"
    assert_equal "OriginalName", material.name
  end

  def test_set_name_invalid_argument
    material = @mats["Solid"]
    assert_raises(TypeError) { material.name = nil      }
    assert_raises(TypeError) { material.name = material }
  end

  # ========================================================================== #
  # method Sketchup::Material.colorize_type
  # http://www.sketchup.com/intl/developer/docs/ourdoc/material#colorize_type

  def test_colorize_type_api_example
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats[0]
    type = material.colorize_type
  end

  def test_colorize_type_solid_material
    skip("Implemented in SU2015") if SU_VERS_INT < 15
#    material = @mats["Solid"]
#    result = material.colorize_type
    result = @mats["Solid"].colorize_type
    assert_equal(Sketchup::Material::COLORIZE_SHIFT, result)
  end

  def test_colorize_type_textured_material
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["Textured"]
    result = material.colorize_type
    assert_equal(Sketchup::Material::COLORIZE_SHIFT, result)
  end

  def test_colorize_type_colorized_textured_material_shifted
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["TexturedShifted"]
    result = material.colorize_type
    assert_equal(Sketchup::Material::COLORIZE_SHIFT, result)
  end

  def test_colorize_type_colorized_textured_material_tinted
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["TexturedTinted"]
    result = material.colorize_type
    assert_equal(Sketchup::Material::COLORIZE_TINT, result)
  end

  def test_colorize_type_incorrect_number_of_arguments_one
    material = @mats["Solid"]
    assert_raises(ArgumentError) { material.colorize_type nil }
  end


  # ========================================================================== #
  # method Sketchup::Material.colorize_type=
  # http://www.sketchup.com/intl/developer/docs/ourdoc/material#colorize_type=

  def test_colorize_type_Set_api_example
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats[0]
    material.colorize_type = Sketchup::Material::COLORIZE_TINT
  end

  def test_colorize_type_Set_solid_material
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["Solid"]
    material.colorize_type = Sketchup::Material::COLORIZE_TINT
    assert_equal Sketchup::Material::COLORIZE_TINT, material.colorize_type
  end

  def test_colorize_type_Set_textured_material
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["Textured"]
    material.colorize_type = Sketchup::Material::COLORIZE_TINT
    assert_equal Sketchup::Material::COLORIZE_TINT, material.colorize_type
  end

  def test_colorize_type_Set_colorized_textured_material_shifted
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["TexturedShifted"]
    material.colorize_type = Sketchup::Material::COLORIZE_TINT
    assert_equal Sketchup::Material::COLORIZE_TINT, material.colorize_type
  end

  def test_colorize_type_Set_colorized_textured_material_tinted
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["TexturedTinted"]
    material.colorize_type = Sketchup::Material::COLORIZE_SHIFT
    assert_equal Sketchup::Material::COLORIZE_SHIFT, material.colorize_type
  ensure
    #discard_model_changes()
  end

  def test_colorize_type_Set_invalid_argument_nil
    material = @mats["TexturedShifted"]
    assert_raises(TypeError) { material.colorize_type = nil }
  end

  def test_colorize_type_Set_invalid_argument_point
    material = @mats["TexturedShifted"]
    assert_raises(TypeError) { material.colorize_type = ORIGIN }
  end

  def test_colorize_type_Set_invalid_argument_string
    material = @mats["TexturedShifted"]
    assert_raises(TypeError) { material.colorize_type = "FooBar" }
  end

  def test_colorize_type_Set_invalid_argument_negative_integer
    material = @mats["TexturedShifted"]
    assert_raises(RangeError) { material.colorize_type = -1 }
  end

  def test_colorize_type_Set_invalid_argument_invalid_enum
    material = @mats["TexturedShifted"]
    assert_raises(ArgumentError) { material.colorize_type = 3 }
  end

  # ========================================================================== #
  # method Sketchup::Material.materialType
  # http://www.sketchup.com/intl/developer/docs/ourdoc/material#materialType

  def test_materialType_api_example
    material = @mats[0]
    type = material.materialType
  end

  def test_materialType_solid_material
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["Solid"]
    result = material.materialType
    assert_equal(0, result)
    # Before SketchUp 2015 we had no constants so the numbers became magic.
    assert_equal(Sketchup::Material::MATERIAL_SOLID, result)
  end

  def test_materialType_textured_material
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["Textured"]
    result = material.materialType
    assert_equal(1, result)
    # Before SketchUp 2015 we had no constants so the numbers became magic.
    assert_equal(Sketchup::Material::MATERIAL_TEXTURED, result)
  end

  def test_materialType_colorized_textured_material_shifted
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["TexturedShifted"]
    result = material.materialType
    assert_equal(2, result)
    # Before SketchUp 2015 we had no constants so the numbers became magic.
    assert_equal(Sketchup::Material::MATERIAL_COLORIZED_TEXTURED, result)
  end

  def test_materialType_colorized_textured_material_tinted
    skip("Implemented in SU2015") if SU_VERS_INT < 15
    material = @mats["TexturedTinted"]
    result = material.materialType
    assert_equal(2, result)
    # Before SketchUp 2015 we had no constants so the numbers became magic.
    assert_equal(Sketchup::Material::MATERIAL_COLORIZED_TEXTURED, result)
  end

  def test_materialType_incorrect_number_of_arguments_one
    material = @mats["Solid"]
    assert_raises(ArgumentError) { material.materialType nil }
  end


  # ========================================================================== #
  # method Sketchup::Material.save_as

  def test_save_as_api_example
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    filename = File.join(ENV['HOME'], 'Desktop', 'su_test.skm')
    material = @mats.add("Hello World")
    material.color = 'red'
    material.save_as(filename)
  end

  def test_save_as
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    filename = File.join(temp_dir, 'TC_Material_save_as.skm')
    material = @mats["Solid"]
    # Make sure there isn't an old version.
    File.delete(filename) if File.exist?(filename)
    refute(File.exist?(filename))
    # Make sure the method actually writes out a material.
    result = material.save_as(filename)
    assert(result)
    assert(File.exist?(filename))
  ensure
    File.delete(filename) if File.exist?(filename)
  end

  def test_save_as_invalid_argument_nil
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    material = @mats["Solid"]
    assert_raises(TypeError) { material.save_as nil }
  end

  def test_save_as_invalid_argument_integer
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    material = @mats["Solid"]
    assert_raises(TypeError) { material.save_as 123 }
  end

  def test_save_as_incorrect_number_of_arguments_zero
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    material = @mats["Solid"]
    assert_raises(ArgumentError) { material.save_as }
  end

  def test_save_as_incorrect_number_of_arguments_two
    skip("Implemented in SU2017") if SU_VERS_INT < 17
    material = @mats["Solid"]
    assert_raises(ArgumentError) { material.save_as 'foo', 'bar' }
  end

  def test_alpha
    material = @mats[0]
    assert_equal(1.0, material.alpha)
  end

  def test_alpha_Set
    material = @mats[0]
    assert_equal(1.0, material.alpha)
    material.alpha = 0.0
    assert_equal(0.0, material.alpha)
    material.alpha = 0.4
    assert_equal(0.4, material.alpha)
    material.alpha = 1.0
    assert_equal(1.0, material.alpha)
  end

  def test_color
    material = @mats[0]
    color = Sketchup::Color.new(144, 143, 146, 0)
    assert_kind_of(Sketchup::Color, material.color)
    assert_equal(color.to_a, material.color.to_a)
  end

  def test_color_Set
    material = @mats.add('Joe')
    color = Sketchup::Color.new(32, 64, 128, 255)
    assert_equal([0, 0, 0, 0], material.color.to_a)

    material.color = color
    assert_equal(color.to_a, material.color.to_a)
  end

  def test_display_name
    material = @mats[0]
    assert_equal("Textured", material.display_name)

    material = @mats["Solid"]
    assert_equal("Solid", material.display_name)
    assert_kind_of(String, material.display_name)
  end

  def test_name_Set
    material = @mats.add('Joe')
    assert_equal("Joe", material.name)
    material.name = "Woof"
    assert_equal("Woof", material.name)
  end

  def test_texture
    texture = @mats[0].texture
    assert(texture.valid?)
    assert_kind_of(Sketchup::Texture, texture)
  end

  def test_texture_Set
    material = @mats.add("Joe")
    assert_equal([0, 0, 0, 0], material.color.to_a)
    file = TEST_JPG
    material.texture = file
    assert_equal([190, 177, 168, 255], material.color.to_a)
    assert_equal(656, material.texture.image_width)
    assert_equal(337, material.texture.image_height)
  end

  def test_texture_Set_properties
    material = @mats.add("Joe")
    assert_equal([0, 0, 0, 0], material.color.to_a)
    file = TEST_JPG
    material.texture = [file, 1024, 768]
    assert_equal([190, 177, 168, 255], material.color.to_a)
    assert_equal(1024, material.texture.width)
    assert_equal(768, material.texture.height)
  end

  def test_texture_Set_image_rep
    material = @mats.add("Joe")
    assert_equal([0, 0, 0, 0], material.color.to_a)
    file = TEST_JPG
    image_rep = Sketchup::ImageRep.new(file)
    material.texture = image_rep
    assert_equal([190, 177, 168, 255], material.color.to_a)
    assert_equal(656, material.texture.image_width)
    assert_equal(337, material.texture.image_height)
  end

  def test_use_alpha_Query
    material = @mats[0]
    refute(material.use_alpha?)
    assert_kind_of(FalseClass, material.use_alpha?)
  end

  def test_write_thumbnail
    material = @mats.add("Joe")
    filename = File.join(temp_dir, 'test_write_thumbnail.png')

    File.delete(filename) if File.exist?(filename)
    refute(File.exist?(filename))
    # Make sure the method actually writes out a material.
    result = material.write_thumbnail(filename, 128)
    assert(result)
    assert(File.exist?(filename))
  ensure
    File.delete(filename) if File.exist?(filename)
  end

  def test_Operator_Equal
    material1 = @mats[0]
    material2 = @mats[0]
    assert(material1 == material2)
    material2 = @mats.add("Joe")
    refute(material1 == material2)
  end
end # class
