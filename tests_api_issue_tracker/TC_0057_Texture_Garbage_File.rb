# frozen_string_literal: true
=begin
————————————————————————————————————————————————————————————————————————————————
SUMT.run d:'tests_api_issue_tracker', f:%w[TC_0057_Texture_Garbage_File.rb]

https://github.com/SketchUp/api-issue-tracker/issues/57
reported by @prachtan

Copyright 2018 MSP-Greg
License: The MIT License (MIT)
————————————————————————————————————————————————————————————————————————————————
=end

class TC_0057_Texture_Garbage_File < SUMT::TestCase

  def test_write_garbage_texture
    start_with_empty_model
    mat = Sketchup.active_model.materials.add '0057'
    mat.texture = get_test_file 'test_small.jpg'
    mat.colorize_type = Sketchup::Material::COLORIZE_TINT
    mat.color = [128, 128, 0]

    assert_equal Sketchup::Material::MATERIAL_COLORIZED_TEXTURED, mat.materialType, \
      'materialType is not MATERIAL_COLORIZED_TEXTURED'

    tx = mat.texture

    assert tx.valid?, 'texture is not valid'

    fn_normal = temp_file 'normal.gif'
    fn_color  = temp_file 'colorized.gif'

    assert tx.write(fn_normal),    'tx.write should not return false when colorize = false'
    assert File.exist?(fn_normal), 'tx.write did not write file when colorize = false'

    refute tx.write(fn_color, true)
    refute File.exist?(fn_color), "Colorized file of type .gif should not be written"
  ensure
    fn_normal and File.exist?(fn_normal) and File.delete(fn_normal)
    fn_color  and File.exist?(fn_color)  and File.delete(fn_color)
  end

end # class
