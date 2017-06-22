class ApplicationJob < ActiveJob::Base
  self.queue_adapter = :sidekiq

  rescue_from StandardError do |exception|
    if self.queue_name.to_s == 'retry'
      raise exception
    else
      wait_time = (Rails.env.test? ? 2 : 30)
      Sidekiq::Logging.logger.warn "Job has failed. Retry in #{wait_time}s. #{exception.to_s}." if Sidekiq::Logging.logger
      retry_job(wait: wait_time, queue: :retry)
    end
  end

  rescue_from Timeout::Error do |exception|
    if self.queue_name.to_s == 'cache'
      retry_job(wait: 1, queue: :slow)
    elsif self.queue_name.to_s == 'slow'
      retry_job(wait: 1, queue: :retry)
    else
      raise exception
    end
  end

  rescue_from ActiveJob::DeserializationError do |exception|
    if self.queue_name.to_s == 'retry'
      # Skip this job. The record has been deleted in the meantime.
      Sidekiq::Logging.logger.warn "Object not found. It has been removed in the meantime. Skipping this job. #{exception.to_s}." if Sidekiq::Logging.logger
    else
      wait_time = (Rails.env.test? ? 2 : 30)
      Sidekiq::Logging.logger.warn "Job has failed. Retry in #{wait_time}s. #{exception.to_s}." if Sidekiq::Logging.logger
      retry_job(wait: wait_time, queue: :retry)
    end
  end

  def with_timeout
    if Rails.env.test?
      yield  # No timeouts in testing.
    elsif self.queue_name.to_s == "cache"
      Timeout::timeout(15.seconds) { yield }
    elsif self.queue_name.to_s == "slow"
      Timeout::timeout(15.minutes) { yield }
    else
      yield
    end
  end

  # This patch tries to fix "(ArgumentError) "wrong number of arguments (given 0, expected 2)".
  #
  # @see https://github.com/rails/rails/issues/22044
  # @see https://github.com/fiedl/your_platform/issues/23
  #
  # TODO: When migrating to rails 5, check if https://github.com/rails/rails/pull/26221 is
  # pulled already.
  #
  def serialize
    serialized = super

    # @see https://github.com/rails/rails/blob/v5.0.0.1/activejob/lib/active_job/core.rb#L116
    if defined?(@serialized_arguments) && @serialized_arguments.present?
      serialized["arguments"] = @serialized_arguments
    end

    serialized
  end
end
