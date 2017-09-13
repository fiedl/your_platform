module StringOverrides

  # The `to_datetime` method is patched to support converting
  # years like "2005", which are interpreted as "2005-01-01".
  #
  def to_datetime
    self.gsub!(/^[ ]*([12][019][0-9][0-9])[ ]*$/, '01.01.\1')
    return nil if self == "-"
    super
  end

  def to_date
    self.gsub!(/^[ ]*([12][019][0-9][0-9])[ ]*$/, '01.01.\1')
    return nil if self == "-"
    super
  end

end

class String
  prepend StringOverrides
end