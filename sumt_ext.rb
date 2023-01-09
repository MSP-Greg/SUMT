# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright 2018 MSP-Greg
# License: The MIT License (MIT)
#———————————————————————————————————————————————————————————————————————————————

if defined?(Sketchup)
  require 'sketchup.rb'
  require 'extensions.rb'
else
  # ????
  return 
end

module SUMT

  #——————————————————————————————————————————————————————————————————— Constants
  PLUGIN_ID       = 'SUMT'.freeze
  PLUGIN_NAME     = 'SUMT'.freeze
  PLUGIN_VERSION  = '0.9.0'.freeze
  PATH            = 'C:/Greg/GitHub/SUMT/lib'

  #——————————————————————————————————————————————————————————————————— Extension
  loader = File.join( PATH, 'sumt.rb' )
  if defined?(Sketchup)
    if !file_loaded?(__FILE__)
      ex = SketchupExtension.new(PLUGIN_NAME, loader)
      ex.description = 'SketchUp Minitest runner'
      ex.version     = PLUGIN_VERSION
      ex.copyright   = 'MSP-Greg © 2018'
      ex.creator     = 'MSP-Greg'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end
  end

end # module SUMT
