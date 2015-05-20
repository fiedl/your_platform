Rails.application.config.active_job.queue_adapter = :sidekiq

# redis is already namspaced
Rails.application.config.active_job.queue_name_prefix = "" 

# Please do not forget to defined the queues in the main app:
#
#     ➜ cat config/sidekiq.yml
#     :queues:
#       - default
#       - notification
#