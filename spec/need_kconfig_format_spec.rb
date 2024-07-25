require 'spec_helper'
require 'yaml'

def check_config_name(name)
  # Check if config name format is valid:
  # 1. not start with CONFIG_
  expect(name.to_s).not_to start_with('CONFIG_'), 'Expected to not start with CONFIG_, but it was not.'
end

def check_config_value(value)
  # Check if value format is valid:
  # 1. only contain n, m, y, or nothing
  # 2. only contain i386, x86_64, or nothing
  # 3. allow hexadecimal and integer
  allowed_formats = /^(n|m|y|i386|x86_64|0x[0-9a-fA-F]+|\d+)$/

  # Check each value against allowed formats
  value.to_s.split(',').map(&:strip).all? do |v|
    # Check if the value matches any of the allowed formats
    expect(v).to match(allowed_formats), "Expected to contain n, m, y, i386, x86_64, integers as value, but got #{v} instead."
  end
end

def preprocess_yaml_file(file_path)
  yaml_content = ''

  File.foreach(file_path) do |line|
    # Skip lines containing conditional directives
    next if line.strip.start_with?('%') || line.strip.empty?

    # Replace specific symbols with their string representations
    line.gsub!(/:(\s*)([!@$%^&*\-_+=`~|\\\/.,:;(){}<>?])/) { ":#{Regexp.last_match(1)}\"#{Regexp.last_match(2)}\"" }

    # Concatenate the remaining lines
    yaml_content << line
  end
  yaml_content
end

def load_yaml_with_conditionals(file_path)
  yaml_content = preprocess_yaml_file(file_path)
  YAML.load(yaml_content)
end

def is_erb_file(file_path)
  File.foreach(file_path) { |line| return true if line.include?('<%') || line.include?('<%=') }
  false
end

describe 'Check need_kconfig from' do
  # Check the config format in include/ dir
  files = Dir.glob("#{LKP_SRC}/include/**/*").select { |file| File.file?(file) }
  files.each do |file|
    begin
      yaml_data = load_yaml_with_conditionals(file)
      # next if yaml_data.nil? || !yaml_data.is_a?(Hash) || is_erb_file(file)
      next unless yaml_data.is_a?(Hash) && !is_erb_file(file)

      kconfig_section = yaml_data['need_kconfig']

      next if kconfig_section.nil?

      it file do
        case kconfig_section
        when String
          check_config_name(kconfig_section)
        when Array
          kconfig_section.each do |config|
            var_name, var_val = config.is_a?(String) ? config.split(':').map(&:strip) : [config.keys[0], config.values[0]]
            check_config_name(var_name)

            # If value is array
            if var_val.is_a?(Array)
              var_val.each do |val|
                check_config_value(val)
              end
            else
              check_config_value(var_val)
            end
          end
        end
      end
    rescue Psych::SyntaxError
      # Expecting need_kconfig will be put in yaml file, so files like include/md/raid_level will be skipped
      next
    end
  end
end
