module TimeMatchers

  # https://gist.github.com/shime/9930893
  # https://stackoverflow.com/a/26207378/2066546
  RSpec::Matchers.define :be_the_same_time_as do |expected|
    match do |actual|
      expect(expected).to be_within(1.second).of actual
    end
  end

end