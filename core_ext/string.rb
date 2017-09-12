module StringOverrides

  def to_datetime
    self.gsub!(/^([12][019][0-9][0-9])$/, '01.01.\1') if self.length == 4
    super
  end

end

class String
  prepend StringOverrides
end