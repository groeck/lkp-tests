#!/usr/bin/env ruby

LKP_SRC ||= ENV['LKP_SRC'] || File.dirname(__dir__)

require 'yaml'
require "#{LKP_SRC}/lib/kernel_tag"
require "#{LKP_SRC}/lib/log"

def check_kernel_version
  context_file = File.join(File.dirname(File.realpath(self['kernel'])), 'context.yaml')
  raise Job::ParamError, "context.yaml doesn't exist: #{context_file}" unless File.exist?(context_file)

  context = YAML.load(File.read(context_file))
  kernel_version = context['rc_tag']
  kernel_version += ".#{context['kernel_patch_level'].to_i}" unless context['kernel_patch_level'].to_i.zero?

  compiler = File.realpath(self['kernel']).include?('clang') ? 'clang' : 'gcc'
  need_version = Array(self['need_kernel_version']).detect { |l| l.include?(compiler) }
  return unless need_version && kernel_version

  raise Job::ParamError, "kernel version not satisfied: #{kernel_version}" unless kernel_match_version?(kernel_version, Array(need_version.split(',').first))
end

check_kernel_version if self['LKP_LOCAL_RUN'] != 1 && self['need_kernel_version'] && self['kernel']
