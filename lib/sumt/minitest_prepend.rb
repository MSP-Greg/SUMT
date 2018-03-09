# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright 2018 MSP-Greg
# License: The MIT License (MIT)
#———————————————————————————————————————————————————————————————————————————————


module SUMT

# Of the methods here, only {__run} overrides its super.
#
module MinitestPrepend

  # Prepended to for three reasons.
  # 1. generation of or use of rerun files
  # 2. adds {TestCase.ste_setup} & {TestCase.ste_teardown} methods
  # 3. Filter suites based on {SUMT.test_files}
  #
  def __run reporter, options
    if SUMT.rr_data
      data = SUMT.rr_data
      suites = data.map { |d|
        ste = Object.const_get d[0]
        ste.instance_variable_set :@r_meths, d[1]
        ste
      }
    else
      suites = Minitest::Runnable.runnables.reject { |s|
        if s.respond_to? :meths_clear
          s.meths_clear ; s.runnable_methods.empty?
        else
          true
        end
      }.shuffle
      unless (ary_files = ::SUMT.test_files).empty?
        suites.select! { |s| ary_files.include? s.fn }
      end
    end

    #————————————————————————————————————————————————————— generate a rerun file
    if SUMT.gen_rerun
      ary = []
      filter = options[:filter] || options[:exclude]
      suites.each { |s|
        fm = filter ? filter_methods(options, s) : s.runnable_methods
        ary << [s.name, fm]
      }
      create_run_file options, ary
    end

    #————————————————————————————————————————————————————————————— run the tests
    suites.map { |suite|
      suite.ste_setup    if suite.respond_to? :ste_setup
      t = suite.run reporter, options
      suite.ste_teardown if suite.respond_to? :ste_teardown
      t
    }
  end

  private
  
  # Filters methods for rerun file generation. New method.
  # @param [Hash]  options standard Minitest
  # @param [Minitest::Runnable] ste a test suite/file class
  #
  def filter_methods(options, ste)
    if options[:filter]
      filter = options[:filter] || "/./"
      filter = Regexp.new $1 if filter =~ %r%/(.*)/%

      filtered_methods = ste.runnable_methods.select { |m|
        filter === m || filter === "#{self}##{m}"
      }
    else
      filtered_methods = ste.runnable_methods.clone
    end
    if options[:exclude]
      exclude = options[:exclude]
      exclude = Regexp.new $1 if exclude =~ %r%/(.*)/%

      filtered_methods.reject! { |m|
        exclude === m || exclude === "#{self}##{m}"
      }
    end
    filtered_methods
  end

  # Creates a yaml rerun file.  New method.
  # @param [Hash]  options standard Minitest
  # @param [Array] ary first element is header data, subsequent elements are
  #   arrays of [<test class name>, <array test method names>].
  #
  def create_run_file(options, ary)
    hdr = ['Run Info', {}]
    hsh = hdr[1]
    hsh[:test_dir]   = SUMT.test_dir
    hsh[:test_files] = SUMT.test_files
    hsh[:seed]       = options[:seed]
    ary.unshift hdr

    filename = "#{SUMT.rpt_data[:log_base]}_s#{options[:seed]}.run"
    filepath = File.join(SUMT::AppFiles.run_file_path, filename)
    puts "    Run log: #{filepath}"
    File.write(filepath, ary.to_yaml)
  end

end # module MinitestPrepend
end # module SUMT

module Minitest

#  class << self ; prepend SUMT::MinitestPrepend ; end
  class << self
    prepend(SUMT::MinitestPrepend)
  end
end
