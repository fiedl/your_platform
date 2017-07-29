# Modify datetime precision.
# To avoid this:
#
#     Failure/Error:
#
#      expected: 2016-04-26 10:10:04.573763343 +0000
#           got: 2016-04-26 10:10:04.573763000 +0000
#
# > This is actually a common issue that occurs with rails app tests.
# > The ruby Time object is very precise in comparison to the time your DB captures.
#
# https://community.codeship.com/t/how-to-solve-time-comparison-issues-with-your-rails-test/669
#
module TimeEqlPrecisionCorrection
  def eql?(other, options = {})
    p "compare #{self.to_s} to #{other.to_s} with eql?"
    return super(other) if options[:super]
    self.round(7).eql?(other.round(7), super: true)
  end

  def <=>(other)
    p "compare #{self.to_s} to #{other.to_s} with <=>"
    return 1 if self.eql?(other)
    super(other)
  end

  def ==(other)
    p "compare #{self.to_s} to #{other.to_s} with =="
    self.eql?(other)
  end

end

class ActiveSupport::TimeWithZone
  prepend TimeEqlPrecisionCorrection
end