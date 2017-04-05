class ActiveJob::Base

  # http://stackoverflow.com/a/38592564/2066546
  # http://edgeapi.rubyonrails.org/classes/ActiveJob/Core.html
  # http://blog.rstankov.com/activejobretry/
  #
  # TODO: Fix this when migrating to rails 5.
  # In rails 5, `deserialize` ist just an instance method,
  # no class method.
  attr_accessor :attempt_number

  def serialize
    super.merge('attempt_number' => (attempt_number || 0) + 1)
  end

  def deserialize(job_data)
    self.attempt_number = job_data['attempt_number'] if self.respond_to? :attempt_number
    self.job_id = job_data['job_id']
    self.queue_name = job_data['queue_name']
    self.serialized_arguments = job_data['arguments']
    super if defined? super
  end

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