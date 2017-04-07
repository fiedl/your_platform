class ApplicationJob < ActiveJob::Base
  self.queue_adapter = :sidekiq

  rescue_from StandardError do |exception|
    if self.queue_name.to_s == 'retry'
      raise exception
    else
      retry_job(wait: 30, queue: :retry)
    end
  end
end
