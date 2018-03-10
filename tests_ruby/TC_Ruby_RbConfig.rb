# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright 2018 MSP-Greg
# License: The MIT License (MIT)
#———————————————————————————————————————————————————————————————————————————————

=begin
SUMT.run %w[TC_Ruby_RbConfig.rb]
=end

class TC_Ruby_RbConfig < SUMT::TestCase

#—————————————————————————————————————————————————————————————— RbConfig::CONFIG
  %w[libdir rubylibprefix sitedir sitelibdir vendordir vendorlibdir].each do |m|
    meth = "test_rbconfig_#{m}".to_sym
    define_method(meth) {
      dir = RbConfig::CONFIG[m]
      assert Dir.exist?(dir), "Directory #{dir} from RbConfig::CONFIG['#{m}'] does not exist"
    }
  end

end # class
