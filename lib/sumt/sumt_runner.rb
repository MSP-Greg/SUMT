# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright 2018 MSP-Greg
# License: The MIT License (MIT)
#———————————————————————————————————————————————————————————————————————————————

# SUMT code is located in both `sumt.rb' and `sumt_runner.rb`.  `sumt.rb' is loaded
# by the extension code, and only contains the {run} method.  When called, it loads
# `sumt_runner.rb` then calls {runner}, which actually tuns the tests.
#
module SUMT

  CONFIG      = File.join(ENV['HOME'], '.sumt')
  SU_VERS_INT = Sketchup.version.to_i

  class << self

  #{—————————————————————————————————————————————————————— Set by run parameters

  # @!group Class Attributes set by run parameters

  # Exclude search string passed to Minitest
  # @return [String,nil]
  attr_reader :exclude

  # Array used for `Dir.glob`, from `f:` or `file_query` parameter
  # @return [Array<String>,nil]
  attr_reader :file_query

  # Output to Visual Studio debugger - future!
  # @return [Boolean,nil]
  attr_reader :gen_debug

  # Generate log files to log_dir
  # @return [Boolean,nil]
  attr_reader :gen_logs

  # Generate rerun info (test selection & order) to yaml file for reuse.
  # @return [Boolean,nil]
  attr_reader :gen_rerun

  # Output UDPSocket data for debugging.
  # @return [Boolean,nil]
  attr_reader :gen_udp

  # Base directory for run & log files
  # @return [String,nil]
  attr_reader :log_dir

  # Name search string passed to Minitest
  # @return [String,nil]
  attr_reader :name

  # Number of test repeats /runs, defaults to 1
  # @return [Integer,nil]
  attr_reader :repeats

  # Rerun file to use for test selection & order
  # @return [String,nil]
  attr_reader :rr_file

  # passed along to MT
  # @return [Integer,nil]
  attr_reader :seed

  # Show skip detail in log summary (without verbose:)
  # @return [Boolean,nil]
  attr_reader :show_skip

  # Temp directory, resets `Sketchup.temp_dir`
  # @return [String,nil]
  attr_reader :temp_dir

  # Base folder for test files
  # @return [String,nil]
  attr_reader :test_dir

  # @!endgroup

  #}

  # Misc data used in reports
  # @return [String,nil]
  attr_reader :rpt_data

  # Rerun test data from `rr_file`
  # @return [String,nil]
  attr_reader :rr_data

  # Current run, see repeats.
  # @return [Integer]
  attr_reader :run_cntr

  # Array of all test file paths, relative to {.test_dir}
  # @return [Array<String>,nil]
  attr_reader :test_files

  # Main method that loads all parameters, sets test environment, runs tests
  def runner(opts)
    init_variables unless instance_variable_defined?(:@exclude)

    ary_remove = []
    ary_tests  = []

    return unless set_opts(opts)

    load_deps unless @loaded

    # if rerunning from file, load data
    @rr_file and load_rerun_info

    @rpt_data = {}

    # check & set @test_dir
    @test_dir = if @test_dir
      if Dir.exist? @test_dir
        @test_dir.freeze
      elsif Dir.exist? (t1 = File.absolute_path("../../#{@test_dir}", __dir__))
        t1.freeze
      else
        raise ArgumentError, "Test directory not found"
      end
    else
      File.absolute_path("../../tests_su", __dir__).freeze
    end.freeze

    # load ary_tests
    if @not_rr && @file_query && !@file_query.empty?
      # add /**/TC_*.rb to any elements that don't end with .rb, which should refer
      # to directories
      glob = @file_query.map { |g| g.end_with?('.rb') ? "**/test_#{g}" : "#{g}/**/test_*.rb" }

      Dir.chdir(@test_dir) { |d| ary_tests = Dir.glob glob }
      if ary_tests.empty?
        UI.messagebox "No matching files in\n\n#{@file_query}"
        return
      end
    else
      Dir.chdir(@test_dir) { |d| ary_tests = Dir.glob '**/test_*.rb' }
    end
    Dir.chdir(@test_dir) { |d| ary_tests = Dir.glob '**/test_*.rb' }

    load_tests ary_tests, ary_remove
    load_reporters

    str =    "     Suites: #{Minitest::Runnable.runnables.length}\n".dup
    if @file_query && !@file_query.empty?
      str << "  Reloading: #{ary_remove.join(' ')}"
    end
    puts str

    run_mt
  end

  private

  def init_variables
    @exclude    = nil
    @file_query = nil
    @gen_debug  = nil
    @gen_logs   = nil
    @gen_rerun  = nil
    @gen_udp    = nil
    @log_dir    = nil
    @name       = nil
    @repeats    = 1
    @rr_file    = nil
    @seed       = nil
    @show_skip  = nil
    @temp_dir   = nil
    @test_dir   = nil
    @rpt_data   = nil
    @rr_data    = nil
    @run_cntr   = 0
    @test_files = nil
    @verbose    = nil

    @loaded     = nil        # true if SUMT requires are loaded
    @load_all   = nil        # loads all tests
    @rpt_data   = {}         # Data shared with reports

    @not_rr     = true
  end

  # Loads parameters used in {.run} call
  def set_opts(opts)
    if opts.key? :save_opts
      require 'psych'
      opts.delete :save_opts
      begin
        File.open(CONFIG, 'w') { |f| f.write opts.to_yaml }
        return false
      rescue
        UI.messagebox "Config file (#{CONFIG}) is not writable?"
      end
    end

    @opts = opts
    # ordered by short kw
    @test_dir   = parse_opt :d , :test_dir  , @test_dir
    @exclude    = parse_opt :e , :exclude   , @exclude
    @file_query = parse_opt :f , :file_query, @file_query

    @gen_debug  = parse_opt :gd, :gen_debug , @gen_debug
    @gen_logs   = parse_opt :gl, :gen_logs  , @gen_logs
    @gen_rerun  = parse_opt :gr, :gen_rerun , @gen_rerun
    @gen_udp    = parse_opt :gu, :gen_udp   , @gen_udp

    @log_dir    = parse_opt :ld, :log_dir   , @log_dir
    @name       = parse_opt :n , :name      , @name
    @repeats    = parse_opt :r , :repeats   , @repeats
    @rr_file    = parse_opt :rr, :rr_file   , @rr_file
    @seed       = parse_opt :s , :seed      , @seed
    @show_skip  = parse_opt :ss, :show_skip , @show_skip
    @temp_dir   = parse_opt :td, :temp_dir  , @temp_dir
    @verbose    = parse_opt :v , :verbose   , @verbose
    @repeats = 1 if @repeats == nil
    true
  end

  # Set options array to be passed to Minitest.run
  def mt_opts
    opts_ary = []
    opts_ary << "--verbose"               if @verbose
    opts_ary << "--seed"    << @seed.to_s if @seed
    opts_ary << "--name"    << @name      if (@name.is_a?(String)    || @name.is_a?(Regexp))
    opts_ary << "--exclude" << @exclude   if (@exclude.is_a?(String) || @exclude.is_a?(Regexp))
    opts_ary
  end

  # Set variable based in calling parameters
  # @param [Symbol] s short calling option symbol
  # @param [Symbol] l long calling option symbol
  # @param [Object] iv variable to set
  def parse_opt(s, l, iv)
    return @opts[l] if @opts.key? l
    return @opts[s] if @opts.key? s
    iv
  end

  # Sets info in {.rpt_data} hash, used by reports for header info, etc.
  def set_rpt_data
    t = @rpt_data
    tn = Time.now
    t[:start_time] = tn
    t[:timestamp]  = tn.strftime('%F_%H-%M-%S')
    t[:log_base]   = "SUMT_#{t[:timestamp]}_su#{SU_VERS_INT}"
  end

  # Loads dependencies
  def load_deps
    require 'stringio'
    require 'minitest'

    require_relative 'console'
    require_relative 'assertions'
    require_relative 'testcase'
    require_relative 'minitest_prepend'
    require_relative 'minitest_test_runnable_prepend.rb'
    require_relative 'menu_guard.rb'
    require_relative 'observer_evt_to_hsh.rb'
    require_relative 'observer_evt_to_queue.rb'
    require_relative 'system_files.rb'
    require_relative 'app_files.rb'
    require_relative 'file_reporter.rb'

    extend AppFiles

    @loaded = true
  end

  # Loads log & udp reporter files
  def load_reporters
    mt_exts = Minitest.extensions

    if @gen_logs
      require_relative 'file_reporter'
      mt_exts << 'file' unless mt_exts.include? 'file'
    elsif @gen_logs == false
      mt_exts.delete 'file'
    end

    if @gen_udp
      require 'socket'
      require_relative 'udp_reporter'
      mt_exts << 'udp' unless mt_exts.include? 'udp'
    elsif @gen_udp == false
      mt_exts.delete 'udp'
    end
  end

  # If a rerun file is used, loads data into @rr_data and other variables
  def load_rerun_info
    if File.exist? @rr_file
      rr_file = @rr_file
    elsif !File.exist? (rr_file = "#{@log_dir}/rerun/#{@rr_file}")
      raise ArgumentError, "Can't find rerun file #{@rr_file}"
    end
    require 'psych'
    @rr_data = Psych.load_file(rr_file)
    rr_hdr = @rr_data.shift[1]
    @test_dir   = rr_hdr[:test_dir]
    @test_files = rr_hdr[:test_files]
    @not_rr = false
  end

  # Loads (and, if required, reloads) test files
  def load_tests(ary_tests, ary_remove)
    if ary_tests.empty?
      puts "\n Test Files: ALL"
      @rpt_data[:test_files] = 'All'
      Minitest::Runnable.runnables.select! { |r|
        if r.respond_to? :fn
          fn = r.fn
          # puts "Suite #{fn}"
          #if fn.start_with?('TC_') || fn =~ /\/TC_/
          if fn.start_with?('test_') || fn =~ /\/test_/
            ary_remove << r.to_s.to_sym if Object.const_defined?(r.name)
            true
          else
            false
          end
        else
          false
        end
      }
    else
      str = ary_tests.join(', ')
      puts "\n Test Files: #{str}", ""
      Minitest::Runnable.runnables.select! { |r|
        if r.respond_to?(:fn)
          if ary_tests.include? r.fn
            parent_obj = Object
            if r.to_s.include? '::'
              r_ary = r.to_s.split '::'
              const = r_ary.pop.to_sym
              r_ary.each { |obj| parent_obj = parent_obj.const_get(obj.to_sym) }
            else
              const = r.name.to_sym
            end
            ary_remove << [parent_obj, const] if parent_obj.const_defined?(const)
            true
          else
            false
          end
        else
          false
        end
      }
    end
    ary_remove.each do |parent_obj, const|
      parent_obj.send :remove_const, const
    end

    # (re)load files
    Minitest::Runnable.runnables.clear
    GC.start

    Dir.chdir(@test_dir) { |d|
      stderr = $stderr
      $stderr = StringIO.new

      if @load_all or ary_tests.empty?
        files = Dir.glob "**/test_*.rb"
      else
        files = ary_tests
      end

      $LOAD_PATH.unshift @test_dir
      files.each { |fn| load "./#{fn}" }
      $LOAD_PATH.shift

      $stderr.flush
      $stderr = stderr
    }
    @test_files = ary_tests
  end

  # After prep is finished, run tests
  def run_mt
    # first things first...
    verbose = $VERBOSE
    $VERBOSE = nil
    o_stdout = $stdout
    o_stderr = $stderr
    $stdout = SUMT::SUMT_CONSOLE

    if @temp_dir && Dir.exist?(@temp_dir)
      env = {}
      env['TMP']    = ENV['TMP']
      env['TEMP']   = ENV['TEMP']
      env['TMPDIR'] = ENV['TMPDIR']

      ENV['TMP']    = @temp_dir
      ENV['TEMP']   = @temp_dir
      ENV['TMPDIR'] = @temp_dir
    else
      env = nil
    end

    opts = mt_opts

    1.upto(@repeats) { |r|
      set_rpt_data
      @run_cntr = r
      @repeats > 1 and $stdout.write("    Running: %2d/%d\n\n" % [r, @repeats])
      ::Minitest.run opts
      puts '—' * 85
      r != @repeats and remove_temp_files  # remove temp files for all but last run
    }

    model = Sketchup.active_model
    model.respond_to?(:close) and model.close(true)
    Sketchup.file_new

  ensure
    $VERBOSE = verbose
    srand if @seed
    $stdout = o_stdout
    $stderr = o_stderr

    if env
      ENV['TMP']    = env['TMP']
      ENV['TEMP']   = env['TEMP']
      ENV['TMPDIR'] = env['TMPDIR']
    end
  end

  # Deletes temp files when using repeats
  def remove_temp_files
    files = Dir.glob "#{Sketchup.temp_dir}/SUMT/**/*.*"
    FileUtils.rm_f files
  end

  end # class << self

  # Load CONFIG file options
  if File.exist? CONFIG
    require 'psych'
    opts = Psych.load_file CONFIG
    set_opts opts
  end

end # SUMT
