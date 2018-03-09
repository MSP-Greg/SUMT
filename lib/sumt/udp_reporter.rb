# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright 2018 MSP-Greg
# License: The MIT License (MIT)
#———————————————————————————————————————————————————————————————————————————————

module SUMT
class UDPReporter < MiniTest::StatisticsReporter

  attr_accessor :sync
  attr_accessor :old_sync
  @@io = nil

  # Exists in case one needs to debug tests using UDP, via
  # `SUMT::UDPReporter.io.puts`.  Not used anywhere else.
  def self.io
    @@io
  end
  
  def initialize(options)
    skt = UDPSocket.new
    skt.connect "127.0.0.1", 50_000
    super(skt, options)
    @time_by_class = Hash.new { |h,k| h[k] = 0 }
  end

  def start
    super
    @@io = io
    str = "Run seed: #{options[:seed]}"
    if SUMT.repeats != 1
      io.write "%-69s  Running: %2d/%d\n\n" % [str, SUMT.run_cntr, SUMT.repeats]
    else
      io.write "#{str}\n\n"
    end
  end

  def prerecord(klass, name)
    io.write "#{klass}  #{name}".ljust(76)
  end

  def record(result)
    super
    io.write " %5.2f  %s\n" % [result.time, result.result_code]
  end

  def report
    super
    io.sync = self.old_sync
    io.puts [statistics, summary, '—' * 85, '']
  ensure
    io.flush
    io.close
    io = nil
  end
  
  def statistics
    "\nFinished in %.3fs, %.2f runs/s, %.2f assertions/s.\n" %
      [total_time, count / total_time, assertions / total_time]
  end

  def aggregated_results
    filtered_results = results.dup
    filtered_results.reject!(&:skipped?) unless options[:verbose] || SUMT.show_skips

    filtered_results.each_with_index.map { |result, i|
      "\n%3d) %s" % [i+1, result]
    }.join("\n") + "\n"
  end

  def summary
    "%d runs, %d assertions, %d failures, %d errors, %d skips" %
      [count, assertions, failures, errors, skips]
  end

end # class
end # module SUMT

module Minitest
  def self.plugin_udp_init(options)
    self.reporter << ::SUMT::UDPReporter.new(options)
  end
end