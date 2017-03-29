class ApplicationJob < ActiveJob::Base
  self.queue_adapter = :sidekiq
  attr_accessor :attempt_number

  def serialize
    # http://stackoverflow.com/a/38592564/2066546
    # http://edgeapi.rubyonrails.org/classes/ActiveJob/Core.html
    super.merge('attempt_number' => (attempt_number || 0) + 1)
  end

  # This method is for rails 5.
  def deserialize(job_data)
    attempt_number = job_data['attempt_number']
    super
  end

  rescue_from StandardError do |exception|
    # There are cases where sidekiq is too fast, i.e. the background worker
    # begins to process before the record is accessible through the database.
    # Just retry in a couple of seconds.
    retry_job(wait: 30, queue: :retry) if attempt_number < 5
  end

end

class ActiveJob::Base

  # This method is for rails 4.
  def self.deserialize(job_data)
    job = super
    job.attempt_number = job_data['attempt_number']
    job
  end

end