#Rails.application.config.active_job.queue_adapter = :inline
Rails.application.config.active_job.queue_adapter = :sidekiq

# We use a custom fetcher to process cache jobs in reverse order,
# i.e. newest first. But avoid this in the test environment
# as all jobs are performed inline there.
require 'sidekiq/fetch_newest_first' unless Rails.env.test?

# redis is already namspaced
Rails.application.config.active_job.queue_name_prefix = ""