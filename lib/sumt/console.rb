# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
#
# Copyright 2013-2014 Trimble Navigation Ltd.
# License: The MIT License (MIT)
#
#———————————————————————————————————————————————————————————————————————————————

module SUMT

  BASE_CONSOLE_CLASS = if    defined? Sketchup ; Sketchup::Console
                       elsif defined? Layout   ; Layout::Console
                       end

  # In order to run in the SketchUp Ruby console there needs to be more methods
  # similar to the IO class. The methods are implemented as needed and behavior
  # is copied from the IO class.
  # NOTE: These should be removed if SketchUp and/or LayOut implements them
  # natively. Both applications should be in sync for the capabilities of the
  # console.

  #  $/  The input  record separator, newline by default.
  #  $\  The output record separator for the print and IO#write. Default is nil.
  #  $,  The output field  separator for the print and Array#join.

  # The SketchUp console is not exactly a subclass of IO, and Minitest expects
  # more methods than it currently has.

  class Console < BASE_CONSOLE_CLASS

    GLUE    = $, || ''
    REC_SEP = $\ || ''

    def print(*args)
      args.compact!
      write "#{ args.join GLUE }#{REC_SEP}" unless args.empty?
      nil
    end

    def puts(*args)
      t_args = args.flatten.map(&:to_s)
      w_args = if t_args.empty?
        [$/]
      else
        t_args.map { |a| (a.empty? || !a.end_with?($/)) ? a + $/ : a }
      end
      write(w_args.join)
    #      write(args.empty? ? $/ : "#{ args.join $/ }#{$/}")
      nil
    end

    def write(*args)
      if args.length == 1
        super args[0]
      else
        args.each {|a| super a }
      end
    end

    def sync=(value)
      # The SketchUp console always output immediately so setting to false is of
      # no use. Currently raising an exception in case the MiniTest framework
      # should depend on setting sync to false.
      # However, it looks like it only tries to set it to true.
      unless value
        raise "#{self.class} doesn't support changing sync."
      end
    end

    def external_encoding
      Encoding::UTF_8
    end

  end # class Console

  SUMT_CONSOLE = Console.new

end # module SUMT
