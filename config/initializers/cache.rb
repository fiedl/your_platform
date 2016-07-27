require_relative './redis'

ENV['REDIS_HOST'] || raise('ENV["REDIS_HOST"] not set, yet.')
::STAGE || raise('::STAGE not set, yet.')

Rails.application.config.cache_store = :redis_store, {
  host: ENV['REDIS_HOST'],
  port: '6379',
  expires_in: if Rails.env.production?
      1.week
    elsif Rails.env.development?
      1.day
    elsif Rails.env.test?
      90.minutes
    end,
  namespace: "#{::STAGE}_cache"
}