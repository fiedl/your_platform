require 'rubygems'

# Switch back to old yaml parser because of l18n problems. 
# Hopefully, they will solve the issues. Then this can be deleted.
# see: http://stackoverflow.com/questions/4980877/rails-error-couldnt-parse-yaml
#require 'yaml'
#YAML::ENGINE.yamler = 'syck'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

