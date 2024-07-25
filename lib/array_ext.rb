#!/usr/bin/env ruby

require 'active_support/core_ext/enumerable'

class Array
  # multiple two arrays via multiple element with same index,
  # return the result array.
  def pos_multiple(an_arr)
    zip(an_arr).map { |v1, v2| v1 * v2 }
  end

  def duplicated_elements
    group_by { |i| i }
      .select { |_k, v| v.size > 1 }
      .map(&:first)
  end

  def mean
    ave = sum.to_f / size
    (ave * 100).round / 100.0
  end

  def median(already_sorted: false)
    return if empty?

    sort! unless already_sorted
    m_pos = size / 2
    size.odd? ? self[m_pos].to_f : self[m_pos - 1..m_pos].mean
  end
end
