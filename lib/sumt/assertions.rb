# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright 2018 MSP-Greg
# License: The MIT License (MIT)
#———————————————————————————————————————————————————————————————————————————————

module SUMT

module Assertions

  OBS_CB    = Hash.new
  OBS_QUEUE = []

  # Checks for how many different event callers (methods) were called,
  # {assert_obs_event} is used to check how many times a particular method was
  # called.
  # @param [Integer] int number of event callers, defaults to 1.
  def assert_obs_events(int = 1)
    assert_equal int, OBS_CB.length, "#{OBS_CB.length} Observer methods were called, correct number is #{int},  " \
     "The following were called:\n    #{OBS_CB.keys.sort.join(' ')}"
  end

  # Checks Observer callback history by method. Verifies call count, and also
  # a parameter match.
  # @param [Symbol]        sym   The observer event to be checked
  # @param {Integer]       cntr  The number of times the event should have occurred
  # @param [Array<Object>] args The arguments that should be passed to the
  #   observer method.  If the last argument is indeterminate, use a nil.
  #
  def assert_obs_event(sym, cntr, *args)
    assert OBS_CB[sym], "#{sym} not called"
    act_cntr = OBS_CB[sym][0]
    assert_equal cntr, act_cntr, "#{sym} was not called #{cntr} time(s), but #{act_cntr}"

    len = args.length
    cb_args = OBS_CB[sym][1..-1]

    assert_equal len, cb_args.length, "Correct number of passed arguments should be #{args.length}," \
      " but #{cb_args.length} were passed."

    args.compact!
    cb_args = OBS_CB[sym][1, args.length]
    assert_equal args, cb_args, "#{sym} callback arguments don't match. #{msg_args_mismatch args, cb_args}"
  end
  
  def msg_args_mismatch(args, cb_ary)
    str = ''.dup
    args.each.with_index { |a, i|
      if Sketchup::Entity === a && !a.deleted?
        if a.typename != cb_ary[i].typename
          str << "\n  typename return parameter #{i+1} is a #{cb_ary[i].typename}, should be a #{a.typename}"
        end
      elsif a != cb_ary[i]
        str << "\n  return parameter #{i+1} is a #{cb_ary[i].class}, should be a #{a.class}"
      end
    }
    str
  end

end # module Assertions
end # module SUMT
