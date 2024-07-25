require 'spec_helper'
require "#{LKP_SRC}/lib/bash"

describe 'xfstests' do
  describe 'is_test_in_group' do
    before(:all) do
      @benchmark_root = File.join(LKP_SRC, 'spec', 'benchmark_root')
    end

    [
      { test: 'xfs-no-xfs-bug-on-assert', group: 'xfs-no-xfs-bug-on-assert' },
      { test: 'xfs-115', group: 'xfs-no-xfs-bug-on-assert' },
      { test: 'xfs-276', group: 'xfs-realtime' },
      { test: 'xfs-114', group: 'xfs-scratch-reflink-scratch-rmapbt' },
      { test: 'xfs-307', group: 'xfs-scratch-reflink-[0-9]*' },
      { test: 'xfs-scratch-reflink-00', group: 'xfs-scratch-reflink-[0-9]*' },
      { test: 'xfs-235', group: 'xfs-scratch-rmapbt' },
      { test: 'generic-510', group: 'generic-group-[0-9]*' },
      { test: 'generic-437', group: 'generic-dax' },
      { test: 'generic-457', group: 'generic-log-writes' },
      { test: 'generic-487', group: 'generic-logdev' },
      { test: 'ext4-029', group: 'ext4-logdev' },
      { test: 'xfs-275', group: 'xfs-logdev' },
      { test: 'xfs-realtime', group: 'xfs-realtime.*' },
      { test: 'xfs-realtime-scratch-rmapbt', group: 'xfs-realtime.*' },
      { test: 'generic-scratch-reflink-01', group: '(xfs|generic)-scratch-reflink-[0-9]*' }
    ].each do |entry|
      it "#{entry[:test]} belongs to #{entry[:group]}" do
        expect(Bash.call("source #{LKP_SRC}/lib/tests/xfstests.sh; export BENCHMARK_ROOT=#{@benchmark_root}; is_test_in_group \"#{entry[:test]}\" \"#{entry[:group]}\"; echo $?")).to eq('0')
      end
    end

    [
      { test: 'generic-437', group: 'generic-group-[0-9]*' },
      { test: 'ext4-group-00', group: 'ext4-logdev' },
      { test: 'xfs-115', group: 'generic-dax' },
      { test: 'generic-510', group: 'generic-dax' },
      { test: 'xfs-114', group: 'xfs-scratch-reflink-[0-9]*' },
      { test: 'xfs-scratch-reflink', group: 'xfs-scratch-reflink-scratch-rmapbt' }
    ].each do |entry|
      it "#{entry[:test]} not belongs to #{entry[:group]}" do
        expect(Bash.call("source #{LKP_SRC}/lib/tests/xfstests.sh; export BENCHMARK_ROOT=#{@benchmark_root}; is_test_in_group \"#{entry[:test]}\" \"#{entry[:group]}\"; echo $?")).to eq('1')
      end
    end
  end

  describe 'pattern_to_test' do
    [
      { fs: 'xfs', pattern: '_require_xfs_stress_online_repair$', test: 'xfs-stress-online-repair' },
      { fs: 'generic', pattern: 'holetest', test: 'generic-holetest' },
      { fs: 'xfs', pattern: '_require_no_xfs_bug_on_assert$', test: 'xfs-no-xfs-bug-on-assert' },
      { fs: 'xfs', pattern: '_require_scratch_reflink$ _require_xfs_scratch_rmapbt$', test: 'xfs-scratch-reflink-scratch-rmapbt' },
      { fs: 'generic', pattern: '_scratch_mkfs_blocksized', test: 'generic-scratch-mkfs-blocksized' },
      { fs: 'xfs', pattern: '_require_scratch_reflink$ holetest', test: 'xfs-scratch-reflink-holetest' },
      { fs: 'generic', pattern: 'holetest _require_xfs_stress_online_repair$', test: 'generic-holetest-xfs-stress-online-repair' }
    ].each do |entry|
      it "map #{entry[:fs]} #{entry[:pattern]}" do
        expect(Bash.call("source #{LKP_SRC}/programs/xfstests/pkg/PKGBUILD; pattern_to_test \"#{entry[:fs]}\" \"#{entry[:pattern]}\"")).to eq(entry[:test])
      end
    end
  end
end
