# This job renews the cache of the given `record`.
# Only caches that are older than `options[:time]` are renewed.
#
class RenewCacheJob < ApplicationJob
  queue_as :cache

  def perform(record_or_records, options)
    options[:time] = Time.at(options[:time])

    if record_or_records.respond_to? :each
      record_or_records.each { |record| renew_cache(record, options) }
    else
      renew_cache(record_or_records, options)
    end
  end

  def renew_cache(record, options)
    if record
      if options[:method]
        Rails.cache.renew(options[:time]) { record.send(options[:method]) }
      else
        record.renew_cache
      end
    end
  end

  def self.perform_later(record_or_records, options = {})
    options[:time] = (options[:time] || Time.zone.now).to_i
    super(record_or_records, options)
  end

end