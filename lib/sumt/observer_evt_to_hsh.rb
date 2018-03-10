# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright 2018 MSP-Greg
# License: The MIT License (MIT)
#———————————————————————————————————————————————————————————————————————————————

module SUMT

module ObserverEvtToHsh

  OBS_CB = SUMT::Assertions::OBS_CB

  def initialize(*arg)
    super
    events_clear!
  end

  # Clears events hash
  def events_clear!
    OBS_CB.clear
  end

  # Defines methods for observers as they're called
  def respond_to?(meth, include_private = false)
    return true if super
    if meth =~ /\Aon[A-Z_]/
      self.class.send(:define_method, meth) { |*args|
        # MSP-Greg Add debug switch and branch for method definition
        # puts "\nmeth #{meth}  args.last #{args.last.typename}  #{args.last.is_a?(Sketchup::Entity) ? args.last.entityID : ''}"
        cntr = OBS_CB.key?(meth) ? OBS_CB[meth][0] + 1 : 1
        OBS_CB[meth] = [cntr, args].flatten
      }
      true
    else
      false
    end
  end

end # module ObserverEvtToHsh
end # module
