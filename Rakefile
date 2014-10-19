#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rspec/core/rake_task'
require 'rspec-rerun'

Wingolfsplattform::Application.load_tasks

pattern = "{./spec/**/*_spec.rb,./vendor/engines/**/spec/**/*_spec.rb}"

ENV['RSPEC_RERUN_RETRY_COUNT'] ||= '2'
ENV['RSPEC_RERUN_PATTERN'] ||= pattern

task default: 'rspec-rerun:spec'

# task :default => :spec
# 
# Rake::Task[ :spec ].clear
# RSpec::Core::RakeTask.new( :spec ) do |t|
#   t.pattern = pattern
# end
