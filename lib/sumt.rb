# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright 2018 MSP-Greg
# License: The MIT License (MIT)
#———————————————————————————————————————————————————————————————————————————————


# Short file loaded by Extension Manager.  Main code is in `sumt_runner.rb`.
#
module SUMT
  
  # Stub method that calls {.runner}
  def self.run(**kw)
    require_relative 'sumt/sumt_runner'
    runner kw
    nil
  end
end # module SUMT
