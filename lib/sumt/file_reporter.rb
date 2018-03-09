# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
#
# Copyright 2013-2016 Trimble Inc.
# License: The MIT License (MIT)
#
#———————————————————————————————————————————————————————————————————————————————

module SUMT

class FileReporter < MiniTest::StatisticsReporter

  include AppFiles

  attr_accessor :sync
  attr_accessor :old_sync
  @@io = nil

  SteInfo = Struct.new(:time, :fails, :errors,:skips, :meths, :asserts) do
    def initialize(*)
      super
      self.time   = 0.0
      self.fails  = 0
      self.errors = 0
      self.skips  = 0
      self.meths  = 0
    end
    def data(m_time, type)
      self.time  += m_time
      self.meths += 1
      case type
      when 'F' then self.fails  += 1
      when 'E' then self.errors += 1
      when 'S' then self.skips  += 1
      end
    end
  end

  # Exists in case one needs to debug tests using the log file, via
  # `SUMT::FileReporter.io.puts`.  Not used anywhere else.
  def self.io
    @@io
  end

  def initialize(options)
    super(create_log_file(options), options)
    @ste_info = Hash.new { |h,k| h[k] = SteInfo.new }
  end

  def start
    super
    @@io = io
    @@io.set_encoding(Encoding::UTF_8, Encoding::UTF_8)

    opts = options.dup
    opts.delete(:filter)
    opts.delete(:args)
    opts.delete(:io)
    opts_str = opts.inspect

    str = SUMT.repeats > 1 ? " #{SUMT.run_cntr} of #{SUMT.repeats}" : " 1 of 1"

    io.puts "   SketchUp: #{Sketchup.version}\n"      \
            "       Ruby: #{RUBY_DESCRIPTION}\n"      \
            "       SUMT: #{PLUGIN_VERSION}\n"        \
            "   Minitest: #{Minitest::VERSION}\n\n"   \
            "   Platform: #{Sketchup.platform}\n"     \
            "     Locale: #{Sketchup.get_locale}\n\n" \
            "    Running:#{str}\n"
            "Run options: #{opts_str}\n\n"

    self.sync = io.respond_to? :"sync=" # stupid emacs
    self.old_sync, io.sync = io.sync, true if self.sync
  end

  def report
    super
    io.sync = self.old_sync
    io.puts unless options[:verbose] # finish the dots
    io.puts [aggregated_results, statistics, class_summary]
  ensure
    io.flush
    io.close
  end

  def record(result)
    super
    unless instance_variable_defined? :@has_klass
      @has_klass = result.instance_variable_defined? :@klass
    end
    cls = @has_klass ? result.klass : result.class
    
    io.puts "%-84s %5.2f s  %s" % ["#{cls}##{result.name}",
                                  result.time,
                                  result.result_code]
    @ste_info[cls].data(result.time, result.result_code)
    @ste_info[cls].asserts = self.assertions
  end

  def statistics
    "\nFinished in %.3fs, %.2f runs/s, %.2f assertions/s.\n" %
      [total_time, count / total_time, assertions / total_time]
  end

  def aggregated_results
    filtered_results = results.dup
    filtered_results.reject!(&:skipped?) unless options[:verbose] || SUMT.show_skip

    s = filtered_results.each_with_index.map { |result, i|
      "\n%3d) %s" % [i+1, result]
    }.join("\n") + "\n"
    re_test_dir = Regexp.new Regexp.escape(SUMT.test_dir + '/')
    s.gsub(re_test_dir, '')
  end

  alias to_s aggregated_results

  def summary
    extra = ""

#    extra = "\n\nYou have skipped tests. Run with --verbose for details." if
#      results.any?(&:skipped?) unless options[:verbose] or ENV["MT_NO_SKIP_MSG"]

    str = "%d runs, %d assertions, %d failures, %d errors, %d skips%s" %
      [count, assertions, failures, errors, skips, extra]
    str
  end

  private

  def class_summary
    str = "\n".dup
    fmt =  "%6.2f  %4d   %4d   %4d   %4d  %4d     %s\n"
    str << fmt % [total_time, count, assertions, failures, errors, skips, 'TOTALS']
    str << "  time  runs  asserts  fails errors skips   Class / Suite Name\n"
    running_asserts = 0
    @ste_info.each { |k,v|
      asserts = v.asserts - running_asserts
      str << fmt % [v.time, v.meths, asserts, v.fails, v.errors, v.skips, k]
      running_asserts = v.asserts
    }
    str << "  time  runs  asserts  fails errors skips   Class / Suite Name\n"
    str << fmt % [total_time, count, assertions, failures, errors, skips, 'TOTALS']
    str.gsub(' 0 ', '   ')  # replace zero with hard space (160) to allow tab replacement
  end

  def create_log_file(options)
    filename = "#{SUMT.rpt_data[:log_base]}_s#{options[:seed]}.log"
    filepath = File.join(log_path, filename)
    puts " Logging to: #{filepath}"
    File.open(filepath, 'w')
  end

end # class
end # module SUMT

module Minitest
  def self.plugin_file_init(options)
    self.reporter << ::SUMT::FileReporter.new(options)
  end
end