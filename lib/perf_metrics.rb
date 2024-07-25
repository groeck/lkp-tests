#!/usr/bin/env ruby

LKP_SRC ||= ENV['LKP_SRC'] || File.dirname(__dir__)

require "#{LKP_SRC}/lib/yaml"
require "#{LKP_SRC}/lib/constant"
require "#{LKP_SRC}/lib/log"
require "#{LKP_SRC}/lib/lkp_path"
require "#{LKP_SRC}/lib/programs"
require "#{LKP_SRC}/lib/lkp_pattern"

LKP_SRC_ETC ||= LKP::Path.src('etc')

# => ["tcrypt.", "hackbench.", "dd.", "xfstests.", "aim7.", ..., "oltp.", "sysbench-fileio.", "dmesg."]
def test_prefixes
  stats = LKP::Programs.all_stats
  tests = LKP::Programs.all_tests_and_daemons
  tests = stats & tests
  tests.delete 'wrapper'
  tests.push 'kmsg'
  tests.push 'dmesg'
  tests.push 'stderr'
  tests.push 'last_state'
  tests.map { |test| "#{test}." }
end

module LKP
  class PerfMetrics
    include Singleton

    def initialize
      prefixes = File.read("#{LKP_SRC_ETC}/perf-metrics-prefixes").split

      additional_prefixes = test_prefixes.reject do |test|
        test_name = test[0..-2]
        functional_test?(test_name) || other_test?(test_name) || %w(kmsg dmesg stderr last_state).include?(test_name)
      end

      @prefixes = prefixes + additional_prefixes
    end

    def contain?(name)
      @cache ||= {}

      return @cache[name] if @cache.key? name

      @cache[name] = LKP::PerfMetricsPatterns.instance.contain?(name) || @prefixes.any? { |prefix| name.start_with?(prefix) }
    end
  end
end
