# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright:: Copyright 2015 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen
#———————————————————————————————————————————————————————————————————————————————

require 'fileutils'


# class Sketchup::Texture
# http://www.sketchup.com/intl/developer/docs/ourdoc/texture
class TC_Texture < SUMT::TestCase

  TEMP_DIR = temp_dir

  def setup
    start_with_empty_model
  end

  def teardown
    # ...
  end

  # @param [String] texture_filename
  #
  # @return [Sketchup::Material]
  def load_test_material(texture_filename)
    path = get_test_file texture_filename
    raise "missing file: #{path}" unless File.exist?(path)
    model = Sketchup.active_model
    material = model.materials.add
    material.texture = path
    material
  end

  # @return [String]
  def load_small_texture
    load_test_material('test_small.jpg').texture
  end

  # For testing larger textures to ensure the written textures are not resized.
  #
  # @return [String]
  def load_large_texture
    load_test_material('test_large.jpg').texture
  end

  # @param [Sketchup::Texture] texture
  # @param [String] extension
  #
  # @return [String]
  def get_temp_filename(texture, extension = nil)
    extension ||= File.extname(texture.filename)
    filename = "test_texture_#{texture.object_id}_#{Time.now.to_i}#{extension}"
    File.join(TEMP_DIR, filename)
  end

  # @param [Sketchup::Texture] expected
  # @param [String] texture_filename
  #
  # @param [Sketchup::Material]
  def verify_textures_are_equal(expected, texture_filename)
    material = expected.model.materials.add
    material.texture = texture_filename
    temp_texture = material.texture
    assert_kind_of(Sketchup::Texture, temp_texture)
    assert_equal(expected.image_width, temp_texture.image_width)
    assert_equal(expected.image_height, temp_texture.image_height)
    material
  end


  # ========================================================================== #
  # method Sketchup::Texture.write
  # http://www.sketchup.com/intl/developer/docs/ourdoc/texture#write

  def test_write_api_example
    skip('Implemented in SU2016') if Sketchup.version.to_i < 16
    load_small_texture

    material = Sketchup.active_model.materials[0]
    basename = File.basename(material.texture.filename)
    filename = File.join(Sketchup.temp_dir, basename)
    material.texture.write(filename)
  end

  def test_write_original
    skip('Implemented in SU2016') if Sketchup.version.to_i < 16
    texture = load_large_texture
    temp_file = get_temp_filename(texture)

    result = texture.write(temp_file)
    assert(result, 'Failed to write texture')

    verify_textures_are_equal(texture, temp_file)
  ensure
    File.delete(temp_file) if File.exist?(temp_file)
  end

  def test_write_original_convert_image_type
    skip('Implemented in SU2016') if Sketchup.version.to_i < 16
    texture = load_large_texture
    temp_file = get_temp_filename(texture, '.png')

    result = texture.write(temp_file)
    assert(result, 'Failed to write texture')

    verify_textures_are_equal(texture, temp_file)
  ensure
    File.delete(temp_file) if File.exist?(temp_file)
  end

  def test_write_colorized
    skip('Implemented in SU2016') if Sketchup.version.to_i < 16
    texture = load_large_texture
    temp_file = get_temp_filename(texture)

    material = texture.parent
    original_color = material.color
    material.color = Sketchup::Color.new(128, 0, 0)

    result = texture.write(temp_file, true)
    assert(result, 'Failed to write texture')

    material = verify_textures_are_equal(texture, temp_file)

    # A naive check to make sure the exported texture was colorized.
    assert(material.color != original_color,
      'Exported material was not colorized.')

    # Just a simple check to catch if the export result changes.
    assert_equal([98, 28, 28, 255], material.color.to_a)
  ensure
    File.delete(temp_file) if File.exist?(temp_file)
  end

  def test_write_colorized_convert_image_type
    skip('Implemented in SU2016') if Sketchup.version.to_i < 16
    texture = load_large_texture
    temp_file = get_temp_filename(texture, '.png')

    material = texture.parent
    material.color = Sketchup::Color.new(128, 0, 0)

    result = texture.write(temp_file)
    assert(result, 'Failed to write texture')

    verify_textures_are_equal(texture, temp_file)
  ensure
    File.delete(temp_file) if File.exist?(temp_file)
  end

  def test_write_incorrect_number_of_arguments_zero
    skip('Implemented in SU2016') if Sketchup.version.to_i < 16
    texture = load_small_texture
    temp_file = get_temp_filename(texture)

    assert_raises(ArgumentError) do
      texture.write
    end
  ensure
    File.delete(temp_file) if File.exist?(temp_file)
  end

  def test_write_incorrect_number_of_arguments_three
    skip('Implemented in SU2016') if Sketchup.version.to_i < 16
    texture = load_small_texture
    temp_file = get_temp_filename(texture)

    assert_raises(ArgumentError) do
      texture.write(temp_file, false, nil)
    end
  ensure
    File.delete(temp_file) if File.exist?(temp_file)
  end

  def test_write_invalid_argument_nil
    skip('Implemented in SU2016') if Sketchup.version.to_i < 16
    texture = load_small_texture
    temp_file = get_temp_filename(texture)

    assert_raises(TypeError) do
      texture.write(nil)
    end
  ensure
    File.delete(temp_file) if File.exist?(temp_file)
  end

  def test_write_invalid_argument_number
    skip('Implemented in SU2016') if Sketchup.version.to_i < 16
    texture = load_small_texture
    temp_file = get_temp_filename(texture)

    assert_raises(TypeError) do
      texture.write(123)
    end
  ensure
    File.delete(temp_file) if File.exist?(temp_file)
  end

  def test_image_rep
    skip("New in SU2018") if Sketchup.version.to_i < 18
    texture = load_small_texture
    image_rep = texture.image_rep
    assert_kind_of(Sketchup::ImageRep, image_rep)
  end

  def test_image_rep_colorized
    skip("New in SU2018") if Sketchup.version.to_i < 18
    start_with_empty_model
    texture = load_small_texture
    colorized = true

    # colorize it, JUST DO IT!
    material = texture.parent
    material.color = Sketchup::Color.new(128, 64, 32)
    image_rep = texture.image_rep(colorized)
    assert_kind_of(Sketchup::ImageRep, image_rep)
    color = image_rep.color_at_uv(0.5, 0.5)
    assert_kind_of(Sketchup::Color, color)
    assert_equal(160, color.red)
    assert_equal(75, color.green)
    assert_equal(32, color.blue)
  end

  def test_image_rep_not_colorized
    skip("New in SU2018") if Sketchup.version.to_i < 18
    start_with_empty_model
    texture = load_small_texture
    image_rep = texture.image_rep(false)
    assert_kind_of(Sketchup::ImageRep, image_rep)
    color = image_rep.color_at_uv(0.5, 0.5)
    assert_kind_of(Sketchup::Color, color)
    assert_equal(208, color.red)
    assert_equal(191, color.green)
    assert_equal(183, color.blue)
  end

  def test_image_rep_colorized_too_many_arguments
    skip("New in SU2018") if Sketchup.version.to_i < 18
    start_with_empty_model
    texture = load_small_texture
    assert_raises(ArgumentError) do 
       texture.image_rep(true, true)
    end
  end

  def test_image_rep_colorized_empty_argument
    skip("New in SU2018") if Sketchup.version.to_i < 18
    start_with_empty_model
    texture = load_small_texture
    image_rep = texture.image_rep
    assert_kind_of(Sketchup::ImageRep, image_rep)
    color = image_rep.color_at_uv(0.5, 0.5)
    assert_kind_of(Sketchup::Color, color)
    assert_equal(208, color.red)
    assert_equal(191, color.green)
    assert_equal(183, color.blue)
  end
end # class
