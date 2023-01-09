# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright 2018 MSP-Greg
# License: The MIT License (MIT)
#———————————————————————————————————————————————————————————————————————————————

module SUMT

# This is prepended to `Minitest::Test` to allow filtering of suites and methods.
#
module MinitestTestPrepend

  def runnable_methods
    @r_meths ||=  if ::SUMT.test_files.empty?
                    # puts "#{self.name} runnable_methods super"
                    super
                  else
                    # puts "#{self.name} #{self.fn} runnable_methods meths = super"
                    meths = super
                    ::SUMT.test_files.include?(self.fn) ? meths : []
                  end
  end

end # module MinitestTestPrepend

# This is prepended to `Minitest::Runnable` to allow an easy means of getting the file name.
# Isn't an issue when using MT as console app, but we want to always load and
# reload test files without having to close SU.  The constant/class name allows
# us to unload it, but we need the file name to reload it.
#
module MinitestRunnablePrepend
  def inherited klass
    super
    klass.respond_to?(:fn) and klass.fn(caller_locations(1,1).first.absolute_path)
  end
end

end # module SUMT

module Minitest
  class Test

    # @!macro [new] fn
    #   @!attribute [r] fn
    #   File path of class or instance, relative to {SUMT.test_dir}.
    #   @param [string, nil] f filename of class. See MinitestRunnerPrepend.inherited.
    #   @return [string]

    class << self
      prepend SUMT::MinitestTestPrepend

      # @!macro fn
      def fn(f = nil)
        return @fn if instance_variable_defined?(:@fn) && @fn
        t1 = Regexp.new Regexp.escape(SUMT.test_dir + '/')
        @fn ||= if f && File.exist?(f)
          f.sub(t1, '')
        elsif !(t = self.instance_methods false).empty?
          self.instance_method(t[0].to_sym).source_location[0].sub(t1, '')
        elsif !(t = self.singleton_methods false).empty?
          self.singleton_method(t[0].to_sym).source_location[0].sub(t1, '')
        else
          nil
        end
      end

      # Clears `@r_meths`, which is used to hold {runnable_methods}.
      def meths_clear
        @r_meths = nil
      end
    end



=begin
      # @!macro fn
      def fn(f = nil)
        return @fn if @fn
        t1 = Regexp.new Regexp.escape(SUMT.test_dir + '/')
        if f && File.exist?(f)
          @fn = f.sub(t1, '')
        elsif !(t = self.instance_methods false).empty?
          @fn ||= self.instance_method(t[0].to_sym).source_location[0].sub(t1, '')
        elsif !(t = self.singleton_methods false).empty?
          @fn ||= self.singleton_method(t[0].to_sym).source_location[0].sub(t1, '')
        else
          nil
        end
      end

      # Clears `@r_meths`, which is used to hold {runnable_methods}.
      def meths_clear
        @r_meths = nil
      end
    end
=end
    # @!macro fn
    def fn ; self.class.fn ; end

  end # Test

  class Runnable
    class << self ; prepend SUMT::MinitestRunnablePrepend ; end
  end

end # Minitest