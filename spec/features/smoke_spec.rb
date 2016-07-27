require 'spec_helper'

# This implements a smoke test for a docker-based environment.
# See: https://trello.com/c/75kPhmft/1005-smoke-test
#
feature "Smoke test" do

  scenario "Testing a simple redis connection" do
    redis_host = ENV['REDIS_HOST']
    redis_host.should be_present
    expect { Resolv.getaddress(redis_host) }.not_to raise_error
    Resolv.getaddress(redis_host).should be_present
    Redis.new(host: redis_host, port: '6379').info.should be_present
  end

  scenario "Testing the rails cache" do
    Rails.cache.write "foo", "bar"
    Rails.cache.read("foo").should == "bar"
    Rails.cache.should be_kind_of ActiveSupport::Cache::RedisStore
  end

  scenario "Testing the sidekiq connection" do
    Sidekiq.reachable?.should be_true
  end

end