# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Bugra Barin



# class Sketchup::Licensing::ExtensionLicense
# http://www.sketchup.com/intl/developer/docs/ourdoc/extensionlicense
#
# Licensing tests are not repeatable unless we find a way to mock the licensing
# internals. So, just doing API example and parameter tests.
class TC_Licensing_ExtensionLicense < SUMT::TestCase

  def setup
    ext_id = "4e215280-dd23-40c4-babb-b8a8dd29d5ee"
    @ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
  end

  def teardown
    # ...
  end

# ========================================================================== #
  # method Sketchup::Licensing::ExtensionLicense.licensed?
  # http://www.sketchup.com/intl/developer/docs/ourdoc/extensionlicense#licensed?

  def test_licensed_Query_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    ext_id = "4e215280-dd23-40c4-babb-b8a8dd29d5ee"
    ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
    refute ext_lic.licensed?
  end

  def test_licensed_Query_incorrect_number_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) { @ext_lic.licensed? "" }
  end

# ========================================================================== #
  # method Sketchup::Licensing::ExtensionLicense.state
  # http://www.sketchup.com/intl/developer/docs/ourdoc/extensionlicense#state

  def test_state_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    ext_id = "4e215280-dd23-40c4-babb-b8a8dd29d5ee"
    ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
    assert_equal Sketchup::Licensing::NOT_LICENSED, ext_lic.state 
  end

  def test_state_incorrect_number_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) { @ext_lic.state "" }
  end

# ========================================================================== #
  # method Sketchup::Licensing::ExtensionLicense.days_remaining
  # http://www.sketchup.com/intl/developer/docs/ourdoc/extensionlicense#days_remaining

  def test_days_remaining_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    ext_id = "4e215280-dd23-40c4-babb-b8a8dd29d5ee"
    ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
    assert_equal 0, ext_lic.days_remaining
  end

  def test_days_remaining_incorrect_number_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) { @ext_lic.days_remaining "" }
  end

# ========================================================================== #
  # method Sketchup::Licensing::ExtensionLicense.error_description
  # http://www.sketchup.com/intl/developer/docs/ourdoc/extensionlicense#error_description

  def test_error_description_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    ext_id = "4e215280-dd23-40c4-babb-b8a8dd29d5ee"
    ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
    exp = "No license for product (-1)"
    assert_equal exp, ext_lic.error_description
  end

  def test_error_description_incorrect_number_of_arguments
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises(ArgumentError) { @ext_lic.error_description "" }
  end

end # class
