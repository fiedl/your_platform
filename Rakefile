#!/usr/bin/env rake

require File.expand_path('../demo_app/my_platform/config/application', __FILE__)
require 'rspec/core/rake_task'
require 'rspec-rerun'

MyPlatform::Application.load_tasks

pattern = "{./spec/**/*_spec.rb}"

ENV['RSPEC_RERUN_RETRY_COUNT'] ||= '3'
ENV['RSPEC_RERUN_PATTERN'] ||= pattern

task default: 'rspec-rerun:spec'

