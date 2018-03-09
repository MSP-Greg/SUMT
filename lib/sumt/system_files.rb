# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
#
# Copyright 2013-2016 Trimble Inc.
# License: The MIT License (MIT)
#
#———————————————————————————————————————————————————————————————————————————————

require 'fileutils'

module SUMT
module SystemFiles

  APP_DATA_PATH =
    if Sketchup.platform == :platform_win
      path = ENV['APPDATA'].to_s.dup
      path.respond_to?(:force_encoding) and path.force_encoding('UTF-8')
      File.expand_path(path)
    else
      home = File.expand_path(ENV['HOME'].to_s)
      File.join(home, 'Library', 'Application Support')
    end

  def app_data(app_name, *paths)
    File.join(APP_DATA_PATH, app_name, *paths)
  end

end # module
end # module SUMT
