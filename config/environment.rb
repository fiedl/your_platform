# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Wingolfsplattform::Application.initialize!


# default date format,
# see: https://github.com/bernat/best_in_place/issues/89
#Date::DATE_FORMATS.merge!( :default => "%d.%m.%yy" )
