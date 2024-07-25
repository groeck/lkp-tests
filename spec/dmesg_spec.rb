require 'spec_helper'
require "#{LKP_SRC}/lib/dmesg"

describe 'Dmesg' do
  describe 'analyze_error_id' do
    it 'compresses corrupted low memeory messages' do
      line, bug_to_bisect = analyze_error_id '[   61.268659] Corrupted low memory at ffff880000007b08 (7b08 phys) = 27200c000000000'
      expect(line).to eq 'Corrupted_low_memory_at#(#phys)='
      expect(bug_to_bisect).to eq 'Corrupted low memory at .* phys)'
    end

    it 'compresses nbd messages' do
      ['[   31.694592] ADFS-fs error (device nbd10): adfs_fill_super: unable to read superblock',
       '[   31.971391] ADFS-fs error (device nbd7): adfs_fill_super: unable to read superblock'].each do |line|
        line, bug_to_bisect = analyze_error_id line
        expect(line).to eq 'ADFS-fs_error(device_nbd#):adfs_fill_super:unable_to_read_superblock'
        expect(bug_to_bisect).to eq 'ADFS-fs error (device .* adfs_fill_super: unable to read superblock'
      end

      ['[   33.167933] block nbd11: Attempted send on closed socket',
       '[   33.171522] block nbd1: Attempted send on closed socket'].each do |line|
        line, _bug_to_bisect = analyze_error_id line
        expect(line).to eq 'block_nbd#:Attempted_send_on_closed_socket'
      end

      line, _bug_to_bisect = analyze_error_id '[   27.617020] EXT4-fs (nbd3): unable to read superblock'
      expect(line).to eq 'EXT4-fs(nbd#):unable_to_read_superblock'

      line, _bug_to_bisect = analyze_error_id '[   29.177529] REISERFS warning (device nbd3): sh-2006 read_super_block: bread failed (dev nbd3, block 2, size 4096)'
      expect(line).to eq 'REISERFS_warning(device_nbd#):sh-#read_super_block:bread_failed(dev_nbd#,block#,size#)'
    end

    it 'compresses set_feature messages' do
      line, _bug_to_bisect = analyze_error_id '[   14.754513] plip0: set_features() failed (-1); wanted 0x0000000000004000, left 0x0000000000004800'
      expect(line).to eq 'plip#:set_features()failed(-#);wanted#,left'

      line, _bug_to_bisect = analyze_error_id '[   14.626736] bcsf1: set_features() failed (-1); wanted 0x0000000000004000, left 0x0000000000004800'
      expect(line).to eq 'bcsf#:set_features()failed(-#);wanted#,left'
    end

    it 'compresses parport messages' do
      line, _bug_to_bisect = analyze_error_id '[    7.895752] parport0: cannot grant exclusive access for device spi-lm70llp'
      expect(line).to eq 'parport#:cannot_grant_exclusive_access_for_device_spi-lm#llp'
    end

    it 'segfault at ip sp error' do
      ['[   32.298491][  T896] kexec[896]: segfault at 0 ip 0000000000000000 sp 00007ffeaf0ff420 error 14 in dash[561ac3c57000+4000] likely on CPU 38 (core 6, socket 0)',
       '[   32.329378][  T898] lkp-bootstrap[898]: segfault at 0 ip 0000000000000000 sp 00007ffc93657520 error 14 in dash[562112780000+4000] likely on CPU 7 (core 7, socket 0)',
       '[  247.692415][  T962] rsyslogd[962]: segfault at 0 ip 0000000000000000 sp 00007ffec6772100 error 14 likely on CPU 3 (core 3, socket 0)'].each do |line|
        line, _bug_to_bisect = analyze_error_id line
        expect(line).to eq 'segfault_at_ip_sp_error'
      end
    end

    it 'slab cache affected' do
      {
        '[   32.298491][  T896] BUG kmalloc-8: Right Redzone overwritten' => 'BUG_kmalloc-#:Right_Redzone_overwritten',
        '[   14.476643][    C0] BUG kmalloc-512 (Tainted: G S      W       T ): Right Redzone overwritten' => 'BUG_kmalloc-#:Right_Redzone_overwritten',
        '[  264.548980][    C1] BUG kmalloc-rnd-02-96 (Tainted: G        W       TN): Freechain corrupt' => 'BUG_kmalloc-rnd-#-#:Freechain_corrupt'
      }.each do |line, expected|
        line, _bug_to_bisect = analyze_error_id line
        expect(line).to eq expected
      end
    end
  end

  describe 'get_crash_calltraces' do
    files = Dir.glob "#{LKP_SRC}/spec/dmesg/calltrace/dmesg-*"
    files.each do |file|
      it "extracts call trace chunks from #{File.basename file}" do
        actual = get_crash_calltraces file
        expected = File.read(file.sub('dmesg-', 'calltrace-')).split(/^---\n/)

        expect(expected).to eq actual
      end
    end
  end
end
