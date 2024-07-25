#!/usr/bin/env ruby

if RUBY_VERSION < '2.4'
  class Hash
    def transform_values
      Hash[map { |k, v| [k, yield(v)] }] # rubocop:disable Style/HashTransformValues
    end
  end

  class Integer
    def positive?
      self > 0 # rubocop:disable Style/NumericPredicate
    end
  end
end
