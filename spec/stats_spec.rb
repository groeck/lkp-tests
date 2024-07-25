require 'spec_helper'
require "#{LKP_SRC}/lib/stats"
require "#{LKP_SRC}/lib/programs"

describe 'stats' do
  describe 'scripts' do
    yaml_files = Dir.glob ["#{LKP_SRC}/spec/stats/*/*.yaml"]
    yaml_files.each do |yaml_file|
      file = yaml_file.chomp '.yaml'
      it "invariance: #{file}" do
        script = File.basename(File.dirname(file))
        old_stat = File.read yaml_file

        stat_script = LKP::Programs.find_parser(script)
        new_stat = case script
                   when /^(kmsg)$/
                     `RESULT_ROOT=/boot/1/vm- #{stat_script} #{file}`
                   when /^(dmesg|mpstat|fio)$/
                     `#{stat_script} #{file}`
                   else
                     `#{stat_script} < #{file}`
                   end
        raise "stats script exitstatus #{$CHILD_STATUS.exitstatus}" unless $CHILD_STATUS.success?

        expect(new_stat).to eq old_stat
      end
    end
  end

  describe 'kpi_stat_direction' do
    it 'should match the correct value' do
      change_percentage = 1
      a = 'aim9.add_float.ops_per_sec'
      b = 'phoronix-test-suite.aobench.0.seconds'
      c = 'aim9.test'

      expect(kpi_stat_direction(a, change_percentage)).to eq 'improvement'
      expect(kpi_stat_direction(b, change_percentage)).to eq 'regression'
      expect(kpi_stat_direction(c, change_percentage)).to eq 'undefined'
    end
  end
end
