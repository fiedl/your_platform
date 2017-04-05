class ApplicationJob < ActiveJob::Base
  self.queue_adapter = :sidekiq

  rescue_from StandardError do |exception|
    # There are cases where sidekiq is too fast, i.e. the background worker
    # begins to process before the record is accessible through the database.
    # Just retry in a couple of seconds.
    if attempt_number < 5
      retry_job(wait: 30, queue: :retry)
    else
      raise exception
    end
  end

end
