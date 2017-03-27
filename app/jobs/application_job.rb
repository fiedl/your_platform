class ApplicationJob < ActiveJob::Base
  self.queue_adapter = :sidekiq

  def serialize
    # http://stackoverflow.com/a/38592564/2066546
    # http://edgeapi.rubyonrails.org/classes/ActiveJob/Core.html
    super.merge('attempt_number' => (@attempt_number || 0) + 1)
  end

  def deserialize(job_data)
    @attempt_number = job_data['attempt_number']
    super
  end

  rescue_from StandardError do |exception|
    # There are cases where sidekiq is too fast, i.e. the background worker
    # begins to process before the record is accessible through the database.
    # Just retry in a couple of seconds.
    retry_job(wait: 30, queue: :retry) if @attempt_number < 5
  end

end