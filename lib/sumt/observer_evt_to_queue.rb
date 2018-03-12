# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright 2018 MSP-Greg
# License: The MIT License (MIT)
#———————————————————————————————————————————————————————————————————————————————

module SUMT

module ObserverEvtToQueue

  OBS_QUEUE = SUMT::Assertions::OBS_QUEUE

  def initialize(*arg)
    super
    events_clear!
  end

  # Clears events hash
  def events_clear!
    OBS_QUEUE.clear
  end

  # Defines methods for observers as they're called
  def respond_to?(meth, include_private = false)
    return true if super
    if meth =~ /\Aon[A-Z_]/
      self.class.send(:define_method, meth) { |*args|
        OBS_QUEUE << [self.class.name[/[^:]+\Z/], meth, *args]
      }
      true
    else
      false
    end
  end

end # module ObserverEvtToQueue
end # module
