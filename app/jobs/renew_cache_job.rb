# This job renews the cache of the given `record`.
# Only caches that are older than `options[:time]` are renewed.
#
class RenewCacheJob < ApplicationJob
  queue_as :cache

  def perform(record_or_records, options)
    options[:time] = Time.at(options[:time])

    if record_or_records.respond_to? :each
      record_or_records.each { |record| perform_on_record(record, options) }
    else
      perform_on_record(record_or_records, options)
    end
  end

  def perform_on_record(record, options)
    record.running_from_background_job = true
    record.cache_at = options[:time]
    renew_cache(record, options)
    record.running_from_background_job = false
  end

  def renew_cache(record, options)
    if record
      if options[:method]
        Rails.cache.renew(options[:time]) { record.send(options[:method]) if record.respond_to?(options[:method]) }
      elsif options[:methods]
        Rails.cache.renew(options[:time]) do
          options[:methods].each do |method|
            record.send(method) if record.respond_to?(method)
          end
        end
      else
        record.renew_cache
      end
    end
  end

  def self.perform_later(record_or_records, options = {})
    options[:time] = (options[:time] || Time.zone.now).to_i
    options[:method] = options[:method].to_s
    super(record_or_records, options)
  end

end