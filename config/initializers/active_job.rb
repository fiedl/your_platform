Rails.application.config.active_job.queue_adapter = :sidekiq

# redis is already namspaced
Rails.application.config.active_job.queue_name_prefix = ""