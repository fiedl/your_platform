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
        rescue_from_undefined_class_or_module do
          original_fetch(key, {force: @ignore_cache}.merge(options), &block)
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
      
    end
  end
end
