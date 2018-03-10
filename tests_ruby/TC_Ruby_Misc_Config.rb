# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright 2018 MSP-Greg
# License: The MIT License (MIT)
#———————————————————————————————————————————————————————————————————————————————

=begin
SUMT.run %w[TC_Ruby_Misc_Config.rb]
=end

class TC_Ruby_Misc_Config < SUMT::TestCase

  def self.ste_setup
    require 'openssl'
    require 'rubygems'
  end

#——————————————————————————————————————————————————————————————————————— OpenSSL
  def test_openssl_DEFAULT_CERT_FILE
    cert_file = OpenSSL::X509::DEFAULT_CERT_FILE
    assert_instance_of String, cert_file
    assert File.exist?(cert_file), "OpenSSL::X509::DEFAULT_CERT_FILE does not exist"
  end

  def test_openssl_DEFAULT_CERT_DIR
    cert_dir = OpenSSL::X509::DEFAULT_CERT_DIR
    assert_instance_of String, cert_dir
    assert Dir.exist?(cert_dir), "OpenSSL::X509::DEFAULT_CERT_DIR does not exist"
  end

#—————————————————————————————————————————————————————————————————————— RubyGems
  def test_gem_dir
    assert Dir.exist?(Gem.dir), "Gem.dir does not exist"
  end

  def test_gem_user_dir
    assert Dir.exist?(Gem.user_dir), "Gem.user_dir does not exist"
  end
  
  def test_gem_paths_path
    assert_includes Gem.path, Gem.dir,      "Gem.dir is not in Gem.path"
    assert_includes Gem.path, Gem.user_dir, "Gem.user_dir is not in Gem.path"
  end
  
end # class
