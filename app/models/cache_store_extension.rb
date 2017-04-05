# This extends the class of Rails.cache.
# This file is required by the cache_store_extension initializer.
#
module CacheStoreExtension

  def uncached
    @ignore_cache = true
    result = yield
    @ignore_cache = false
    return result
  end

  # All caches called within this block will be renewed, i.e. fresh
  # values calculated.
  #
  # To make sure each value is recalculated only
  # once and to manage dependent values, only cached values older than
  # the given `time` or, by default,
  # the time of calling `renew` are recalculated, which is the key
  # to our 2017 attempt of refactoring the caching system.
  #
  # Internal notes: https://trello.com/c/6dNTE3FL/1084-renew-cache
  #
  # Example:
  #
  #     Rails.cache.renew do
  #       user.complicated_cached_method
  #     end
  #
  # Another example:
  #
  #     class User < ApplicationRecord
  #       def renew_cache
  #         Rails.cache.renew do
  #           complicated_cached_method
  #         end
  #       end
  #     end
  #
  def renew(time = Time.zone.now)
    time = Time.at(time) unless time.kind_of? Time
    @use_renew_cache = self.use_renew_cache?
    store_renew_at_time_for_nested_calls(time)
    yield
    remove_renew_at_time_for_nested_calls
  end

  def store_renew_at_time_for_nested_calls(time)
    (@renew_at_times ||= []) << time
  end
  def remove_renew_at_time_for_nested_calls
    @renew_at_times.pop(1)
  end

  def renew_at
    @renew_at_times.try(:last)
  end

  def renew?
    @renew_at_times.try(:any?)
  end

  def fetch(key, options = {}, &block)
    # We need to have this in local memory. Otherwise, the value might change until
    # we compare the timestamps.
    r = renew_at

    renew_this_key = true if r && (e = entry(key)) && e.created_at && (e.created_at < r)
    renew_this_key = true if @ignore_cache
    renew_this_key = true if options[:force]

    # If the renew_cache mechanism is not to be used, which can be the case
    # in specs or as the mechanism is turned off globally, then just delete
    # the cache rather than renewing it.
    #
    # Then, the cache is fetched on demand. Note that this method does not
    # need to return the calculated result as this code is only executed
    # within `Rails.cache.renew` statements.
    #
    if (not @use_renew_cache) && renew?
      delete(key) if renew_this_key
      return
    end

    # Recalculate the value before calling the original `Rails.cache.fetch`
    # in order not to lock the redis server while calculating the result
    # of the expensive block.
    #
    # This fixes `Redis::TimeoutError` and the issues that arise from
    # blocking the redis server: https://github.com/fiedl/wingolfsplattform/issues/72
    #
    # TODO: Maybe this is not needed after upgrading to redis 3.3.3.
    # See https://github.com/redis/redis-rb/issues/650#issuecomment-278826491
    #
    if renew_this_key || read(key).nil?
      new_value = yield
    end

    super(key, {force: renew_this_key}.merge(options)) { new_value }
  end

  #def fetch(key, options = {}, &block)
  #  rescue_from_undefined_class_or_module do
  #    rescue_from_other_errors(block) do
  #      super(key, {force: @ignore_cache}.merge(options), &block)
  #    end
  #  end
  #end

  def delete_regex(regex)
    if @data
      keys = @data.keys.select { |key| key =~ regex }
      @data.del(*keys) if keys.count > 0
    end
  end

  # This autoloads classes or modules that are required to instanciate
  # the cached objects.
  #
  # See: https://github.com/rails/rails/issues/8167
  # and: https://github.com/dementrock/rails/blob/ceadd4ad63d5be39b2903fe725132d9f9e236448/activesupport/lib/active_support/core_ext/marshal.rb
  #
  def rescue_from_undefined_class_or_module
    begin
      yield
    rescue ArgumentError, NameError => exc
      if exc.message.match(%r|undefined class/module (.+)|)
        $1.constantize
        retry
      else
        raise exc
      end
    end
  end
  private :rescue_from_undefined_class_or_module

  # # This provides a solution to errors like
  # # "year too big to marshal: 16 UTC".
  # #
  # # Note that this error confusingly does not neccessarily have
  # # something to do with caching dates.
  # #
  # def rescue_from_too_big_to_marshal
  #   begin
  #     yield
  #   rescue ArgumentError, NameError => exc
  #     if exc.message.match(%r|year too big to marshal: (.+)|)
  #       yield.reload  # Reloading the ActiveRecord objects can help.
  #     else
  #       raise exc
  #     end
  #   end
  # end

  def rescue_from_other_errors(block_without_fetch, &block_with_fetch)
    begin
      yield
    rescue => e
      p "CACHE: RESCUE: #{e.message}"
      block_without_fetch.call  # Circumvent the caching at all.
    end
  end
  private :rescue_from_other_errors


  # In model specs, it's more efficient to fill the cache when it is needed rather than
  # renewing all caches.
  #
  # If not using renew_cache, the cache is just deleted, not renewed. Filling the cache
  # is on demand then.
  #
  # Note that this won't introduce any bulk deletions. Thus, in terms of testability,
  # this is the same behaviour as when using renew_cache.
  #
  def use_renew_cache?
    not ENV['NO_RENEW_CACHE']
  end

end

ActiveSupport::Cache::Store.send(:prepend, CacheStoreExtension)
