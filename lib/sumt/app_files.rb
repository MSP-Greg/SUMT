# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
#
# Copyright 2013-2016 Trimble Inc.
# License: The MIT License (MIT)
#
#———————————————————————————————————————————————————————————————————————————————

require 'fileutils'
require_relative 'system_files'

module SUMT
module AppFiles

  include SystemFiles

  module_function 

  def log_path
    (path = SUMT.log_dir) && Dir.exist?(path) ? path :
      ensure_exist(app_data(PLUGIN_NAME, 'logs'))
  end

  def run_file_path
    (path = SUMT.log_dir) && Dir.exist?(path) ? 
      ensure_exist(File.join(path, 'rerun'))  :
      ensure_exist(app_data(PLUGIN_NAME, 'rerun'))
  end

  def ensure_exist(path)
    Dir.exist?(path) or FileUtils.mkdir_p(path)
    path
  end

  module_function :log_path, :run_file_path, :ensure_exist
  
end # module AppFiles
end # module SUMT
