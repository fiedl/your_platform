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
  def renew
    @renew = true
    @renew_at ||= Time.zone.now
    yield
    @renew = false
    @renew_at = nil
  end

  def fetch(key, options = {}, &block)
    renew_this_key = true if @renew && @renew_at && entry(key) && entry(key).created_at < @renew_at
    renew_this_key = true if @ignore_cache
    super(key, {force: renew_this_key}.merge(options), &block)
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

end

ActiveSupport::Cache::Store.send(:prepend, CacheStoreExtension)
