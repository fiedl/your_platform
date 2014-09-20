# This extends the class of Rails.cache.
# This file is required by the cache_store_extension initializer.
#
module ActiveSupport
  module Cache
    class Store
  
      def uncached
        @ignore_cache = true
        result = yield
        @ignore_cache = false
        return result
      end
      
      alias_method :original_fetch, :fetch
      def fetch(key, options = {}, &block)
        original_fetch(key, {force: @ignore_cache}.merge(options), &block)
      end
      
    end
  end
end
