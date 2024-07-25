#!/usr/bin/env ruby

LKP_SRC ||= ENV['LKP_SRC'] || File.dirname(File.dirname(__dir__))

require "#{LKP_SRC}/lib/cache"

module Git
  class Base
    include Cacheable

    cache_method :gcommit, cache_key_prefix_generator: lambda(&:object_id)
  end
end

module Git
  class Object
    class Commit
      include Cacheable

      cache_method :release_tag, cache_key_prefix_generator: lambda(&:to_s)
      cache_method :last_release_tag, cache_key_prefix_generator: lambda(&:to_s)
    end
  end
end
