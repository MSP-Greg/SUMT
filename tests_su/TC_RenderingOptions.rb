# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen



require "stringio"


# class Sketchup::RenderingOptions
# http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions
class TC_RenderingOptions < SUMT::TestCase

  def setup
    @model   = Sketchup.active_model
    @options = @model.rendering_options
  end

  def teardown
    # ...
  end


  def mute_puts_statements(&block)
    stdout = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = stdout
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.[]
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#[]

  def test_Operator_Get_api_example
    result = @options["DisplayInstanceAxes"]
  end

  def test_Operator_Get_valid_key
    # Not a whole lot to verify from Ruby here. Just checking that no errors
    # are raised.
    @options["DisplayInstanceAxes"] = true
    assert_equal true, @options["DisplayInstanceAxes"]

    @options["DisplayInstanceAxes"] = false
    assert_equal false, @options["DisplayInstanceAxes"]
  end

  def test_Operator_Get_invalid_key
    assert_nil @options["House of rising sun"]
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.[]=
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#[]=

  def test_Operator_Set_api_example
    options = Sketchup.active_model.rendering_options
    result = options["DisplayInstanceAxes"]
  end

  def test_Operator_Set_valid_key
    current_value = @options["DisplayInstanceAxes"]

    new_value = !current_value
    result = (@options["DisplayInstanceAxes"] = new_value)
    assert_equal(new_value, result)
    assert_equal(new_value, @options["DisplayInstanceAxes"])
  end

  def test_Operator_Set_invalid_key
    result = (@options["House of rising sun"] = true)
    assert_equal(true, result)
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.count
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#count

  def test_count_api_example
    skip("Implemented in SU2014") if SU_VERS_INT < 14
    number = @options.count
  end

  def test_count
    skip("Implemented in SU2014") if SU_VERS_INT < 14
    number = @options.count
    assert_equal(@options.keys.length, number)
  end

  def test_count_by_key_value_pair
    skip("Implemented in SU2014") if SU_VERS_INT < 14
    expected_value = @options['InstanceHidden']
    assert_equal 1, @options.count(['InstanceHidden', expected_value])
  end

  def test_count_by_block_result
    skip("Implemented in SU2014") if SU_VERS_INT < 14
    result = @options.count { |key, value| key =~ /^Fog/ }
    assert_equal(4, result)
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.length
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#length

  def test_length_api_example
    skip("Implemented in SU2014") if SU_VERS_INT < 14
    number = @options.length
  end

  def test_length
    skip("Implemented in SU2014") if SU_VERS_INT < 14
    number = @options.length
    assert_equal(@options.keys.length, number)
  end

  def test_length_bad_params
    skip("Implemented in SU2014") if SU_VERS_INT < 14
    assert_raises(ArgumentError) { @options.length(nil) }
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.size
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#size

  def test_size_api_example
    skip("Implemented in SU2014") if SU_VERS_INT < 14
    number = @options.size
  end

  def test_size
    skip("Implemented in SU2014") if SU_VERS_INT < 14
    assert_equal(@options.keys.size, @options.size)
  end

  def test_size_bad_params
    skip("Implemented in SU2014") if SU_VERS_INT < 14
    assert_raises(ArgumentError) { @options.size nil }
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.each_key
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#each_key

  def test_each_key_api_example
    mute_puts_statements {
      # API example begins here:
      ary = []
      @options.each_key { |key|
        ary << key
        puts key
      }
      ary.reject! { |k| String === k }
      assert_empty ary
    }
  end

  def test_each_key_iterations_matches_length
    count = 0
    @options.each_key { |key| count += 1 }
    expected = @options.length
    assert_equal(expected, count)
  end

  def test_each_key_incorrect_number_of_arguments_one
    assert_raises(ArgumentError) { @options.each_key nil }
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.each_pair
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#each_pair

  def test_each_pair_api_example
    mute_puts_statements {
      # API example begins here:
      Sketchup.active_model.rendering_options.each_pair { |key, value|
        puts "#{key} : #{value}"
      }
    }
  end

  def test_each_pair_iterations_matches_length
    count = 0
    @options.each_pair { |key, value| count += 1 }
    expected = @options.length
    result = count
    assert_equal(expected, result)
  end

  def test_each_pair_incorrect_number_of_arguments_one
    assert_raises(ArgumentError) { @options.each_pair(nil) }
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.each
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#each

  def test_each_api_example
    mute_puts_statements {
      # API example begins here:
      Sketchup.active_model.rendering_options.each { |key, value|
        puts "#{key} : #{value}"
      }
    }
  end

  def test_each_iterations_matches_length
    count = 0
    @options.each { |key, value| count += 1 }
    expected = @options.length
    result = count
    assert_equal(expected, result)
  end

  def test_each_incorrect_number_of_arguments_one
    assert_raises(ArgumentError) { @options.each nil }
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.keys
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#keys

  def test_keys_api_example
    keys = Sketchup.active_model.rendering_options.keys
  end

  def test_keys
    expected_keys = %w[
      BackgroundColor
      BandColor
      ConstructionColor
      DepthQueWidth
      DisplayColorByLayer
      DisplayFog
      DisplayInstanceAxes
      DisplayWatermarks
      DrawDepthQue
      DrawGround
      DrawHidden
      DrawHorizon
      DrawLineEnds
      DrawProfilesOnly
      DrawSilhouettes
      DrawUnderground
      EdgeColorMode
      EdgeDisplayMode
      EdgeType
      ExtendLines
      FaceBackColor
      FaceColorMode
      FaceFrontColor
      FogColor
      FogEndDist
      FogStartDist
      FogUseBkColor
      ForegroundColor
      GroundColor
      GroundTransparency
      HideConstructionGeometry
      HighlightColor
      HorizonColor
      InactiveHidden
      InstanceHidden
      JitterEdges
      LineEndWidth
      LineExtension
      LockedColor
      MaterialTransparency
      ModelTransparency
      RenderMode
      SectionActiveColor
      SectionCutWidth
      SectionDefaultCutColor
      SectionInactiveColor
      ShowViewName
      SilhouetteWidth
      SkyColor
      Texture
      TransparencySort
    ]
    if SU_VERS_INT >= 7
      expected_keys += %w{
        DisplayDims
        DisplaySketchAxes
        DisplayText }
    end
    if SU_VERS_INT >= 8
      expected_keys += %w{
        InactiveFade
        InstanceFade }
    end
    if SU_VERS_INT >= 14
      expected_keys += %w{ DisplaySectionPlanes }
    end
    if SU_VERS_INT >= 15
      expected_keys += %w{
        DisplaySectionCuts
        SectionCutDrawEdges
        DrawBackEdges }
    end
    if SU_VERS_INT >= 18
      expected_keys += %w{
        SectionCutFilled
        SectionDefaultFillColor }
    end
    expected_keys.sort!
    keys = @options.keys
    assert_kind_of(Array, keys)
    assert_equal(expected_keys.size, keys.size)
    keys.sort!
    max = [expected_keys.size, keys.size].max
    max.times { |i| assert_equal expected_keys[i], keys[i] }
  end

  def test_keys_incorrect_number_of_arguments_one
    assert_raises(ArgumentError) { @options.keys nil }
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.add_observer
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#add_observer

  def test_add_observer_api_example
    observer = Sketchup::RenderingOptionsObserver.new # Dummy observer.
    result = Sketchup.active_model.rendering_options.add_observer(observer)
  ensure
    @options.remove_observer(observer)
    observer = nil
  end

  def test_add_observer
    observer = Sketchup::RenderingOptionsObserver.new
    result = @options.add_observer(observer)
    assert_equal(true, result)
  ensure
    @options.remove_observer(observer)
    observer = nil
  end

  def test_add_observer_incorrect_number_of_arguments_two
    observer = Sketchup::RenderingOptionsObserver.new
    assert_raises(ArgumentError) { @options.add_observer observer, nil }
  ensure
    @options.remove_observer(observer)
    observer = nil
  end


  # ========================================================================== #
  # method Sketchup::RenderingOptions.remove_observer
  # http://www.sketchup.com/intl/developer/docs/ourdoc/renderingoptions#remove_observer

  def test_remove_observer_api_example
    observer = Sketchup::RenderingOptionsObserver.new # Dummy observer.
    @options.add_observer(observer)
    result = @options.remove_observer(observer)
  ensure
    @options.remove_observer(observer)
    observer = nil
  end

  def test_remove_observer
    observer = Sketchup::RenderingOptionsObserver.new
    @options.add_observer(observer)
    assert_equal(true , @options.remove_observer(observer))
    assert_equal(false, @options.remove_observer(observer))
  ensure
    @options.remove_observer(observer)
    observer = nil
  end

  def test_remove_observer_incorrect_number_of_arguments_two
    observer = Sketchup::RenderingOptionsObserver.new
    @options.add_observer(observer)
    assert_raises(ArgumentError) { @options.remove_observer observer, nil }
  ensure
    @options.remove_observer(observer)
    observer = nil
  end


  # ========================================================================== #

  def test_constants
    expected_constants = %w{
      ROPAssign
      ROPDrawHidden
      ROPEditComponent
      ROPSetBackgroundColor
      ROPSetConstructionColor
      ROPSetDepthQueEdges
      ROPSetDepthQueWidth
      ROPSetDisplayColorByLayer
      ROPSetDisplayDims
      ROPSetDisplayFog
      ROPSetDisplayInstanceAxes
      ROPSetDisplaySketchAxes
      ROPSetDisplayText
      ROPSetDrawGround
      ROPSetDrawHorizon
      ROPSetDrawUnderground
      ROPSetEdgeColorMode
      ROPSetEdgeDisplayMode
      ROPSetEdgeType
      ROPSetExtendEdges
      ROPSetExtendLines
      ROPSetFaceColor
      ROPSetFaceColorMode
      ROPSetFogColor
      ROPSetFogDist
      ROPSetFogHint
      ROPSetFogUseBkColor
      ROPSetForegroundColor
      ROPSetGroundColor
      ROPSetGroundTransparency
      ROPSetHideConstructionGeometry
      ROPSetHighlightColor
      ROPSetJitterEdges
      ROPSetLineEndEdges
      ROPSetLineEndWidth
      ROPSetLineExtension
      ROPSetLockedColor
      ROPSetMaterialTransparency
      ROPSetModelTransparency
      ROPSetProfileEdges
      ROPSetProfileWidth
      ROPSetProfilesOnlyEdges
      ROPSetRenderMode
      ROPSetSectionActiveColor
      ROPSetSectionCutWidth
      ROPSetSectionDefaultCutColor
      ROPSetSectionDisplayMode
      ROPSetSectionInactiveColor
      ROPSetSkyColor
      ROPSetTexture
      ROPSetTransparencyObsolete
      ROPTransparencySortMethod
    }.sort
    actual_constants = Sketchup::RenderingOptionsObserver.constants.sort
    actual_constants.each_with_index { |constant, index|
      expected = expected_constants[index]
      assert_equal(expected, constant.to_s)
      assert_not_nil(constant)
    }
  end


end # class
