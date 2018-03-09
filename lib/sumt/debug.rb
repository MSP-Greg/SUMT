#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Navigation Ltd.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


module SUMT

  module Debugger

    # SUMT::Debugger.attached?
    def self.attached?
      require 'Win32API'
      @IsDebuggerPresent ||=
        Win32API.new('kernel32', 'IsDebuggerPresent', 'V', 'I')
      @IsDebuggerPresent.call == 1
    end

    # SUMT::Debugger.break
    def self.break
      if self.attached?
        require 'Win32API'
        @DebugBreak ||=
          Win32API.new('kernel32', 'DebugBreak', 'V', 'V')
        @DebugBreak.call
      else
        # SketchUp crashes without BugSplat or triggering a debugger if none is
        # attached.
        false
      end
    end

    # SUMT::Debugger.output
    def self.output(value)
      return nil unless SUMT.settings[:debugger_output_enabled]
      require 'Win32API'
      @OutputDebugString ||=
        Win32API.new('kernel32', 'OutputDebugString', 'P', 'V')
      @OutputDebugString.call("#{value}\n\0")
    end

    def self.debugger_output?
      SUMT.settings[:debugger_output_enabled]
    end

    # SUMT::Debugger.debugger_output = true
    def self.debugger_output=(value)
      SUMT.settings[:debugger_output_enabled] = value ? true : false
    end

    def self.time(title, &block)
      start = Time.now
      block.call
    ensure
      lapsed_time = Time.now - start
      self.output("SUMT::Debugger.time: #{title} #{lapsed_time}s")
      nil
    end

  end # module Debug

  # Calling IsDebuggerPresent doesn't appear to detect the Script Debugger.
  # As a workaround to avoid the break in window.onerror we keep track of this
  # flag for the session. It will be incorrect if debugging is cancelled.
  module ScriptDebugger

    # SUMT::ScriptDebugger.attached?
    def self.attached?
      @attached ||= false
      @attached
    end

    def self.attach
      @attached = true
    end

  end # module Debug

end # module
