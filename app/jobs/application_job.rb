class ApplicationJob < ActiveJob::Base
  self.queue_adapter = :sidekiq
  attr_accessor :attempt_number

  def serialize
    # http://stackoverflow.com/a/38592564/2066546
    # http://edgeapi.rubyonrails.org/classes/ActiveJob/Core.html
    super.merge('attempt_number' => (attempt_number || 0) + 1)
  end

  def deserialize(job_data)
    self.attempt_number = job_data['attempt_number'] if self.respond_to? :attempt_number
    self.job_id = job_data['job_id']
    self.queue_name = job_data['queue_name']
    self.serialized_arguments = job_data['arguments']
    super if defined? super
  end

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

# This is for rails 4. TODO: Remove when migrating to rails 5.
# http://blog.rstankov.com/activejobretry/
#
if ActiveJob::Base.method_defined?(:deserialize)
  fail 'This is no longer needed.'
else
  class ActiveJob::Base
    def self.deserialize(job_data)
      job = job_data['job_class'].constantize.new
      if job.respond_to? :deserialize
        job.deserialize(job_data)
        job
      else
        super
      end
    end
  end
end