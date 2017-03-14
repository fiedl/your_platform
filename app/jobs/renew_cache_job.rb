class RenewCacheJob < ApplicationJob
  queue_as :cache

  # This job renews the cache of the given `record`.
  # Only caches that are older than `time` are renewed.
  #
  def perform(record_or_records, time_i)
    time = Time.at(time_i)
    if record_or_records.respond_to? :each
      record_or_records.each { |record| record.try(:renew_cache, time) }
    else
      record_or_records.try(:renew_cache, time)
    end
  end

  def self.perform_later(record_or_records, time = Time.zone.now)
    super(record_or_records, time.to_i)
  end


end