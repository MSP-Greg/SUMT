# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright 2018 MSP-Greg
# License: The MIT License (MIT)
#———————————————————————————————————————————————————————————————————————————————

module SUMT

module Assertions

  OBS_CB = Hash.new

  # Checks for how many different event callers (methods) were called,
  # {assert_obs_event} is used to check how many times a particular method was
  # called.
  # @param [Integer] int number of event callers, defaults to 1.
  def assert_obs_events(int = 1)
    assert_equal int, OBS_CB.length, "#{OBS_CB.length} Observer methods were called, correct number is #{int},  " \
     "The following were called:\n    #{OBS_CB.keys.sort.join(' ')}"
  end

  # Checks Observer callback history by method. Verifies call count, and also
  # a parameter match, if desired.
  #
  # The arguments passed after the symbol can be done three ways:
  # 1. Parameters matching the callback parameters.  This will assume that the
  #    method is only called once.
  # 2. Parameters matching the callback parameters, along with an `Integer` for 
  #    method call count.
  # 3. A single `Integer`.  This is used when that parameters maybe indeterminate,
  #    like a `ComponentDefinitionList.purge_unused`.  Note that the parameters
  #    can be a partial list.
  #
  # @param [Symbol]        sym   The observer method to be checked
  # @param [Array<Object>] args The arguments that should be passed to the
  #   observer method.  Last optional argument is the method call count, and is
  #    set to one if not included.
  #
  def assert_obs_event(sym, *args)
    assert OBS_CB[sym], "#{sym} not called"
    exp_len = Integer === args.last ? args.pop : 1
    act_len = OBS_CB[sym].pop
    assert_equal exp_len, act_len, "#{sym} was not called #{exp_len} time(s), but #{act_len}"
    # below
    unless args.empty?
      if (len = args.length) == OBS_CB[sym].length
        assert_equal args, OBS_CB[sym], "#{sym} callback arguments don't match"
      else
        assert_equal args[0, len], OBS_CB[sym][0, len], "#{sym} callback arguments don't match"
      end
    end
  end

end # module Assertions
end # module SUMT
