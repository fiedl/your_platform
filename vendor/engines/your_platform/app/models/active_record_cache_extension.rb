module ActiveRecordCacheExtension
  extend ActiveSupport::Concern
  
  def cached(method_name, arguments = nil)
    Rails.cache.fetch([self, method_name, arguments], expires_in: 1.week) do
      
      # Call the method, with or without arguments.
      result = arguments ? send(method_name, *arguments) : send(method_name)
      
      # Not all ActiveRecord::Relation objects can be stored in cache.
      # Convert them to Arrays. Otherwise, this might raise an 'cannot dump' error.
      result = result.to_a if result.kind_of? ActiveRecord::Relation
      
      # This circumvents a bug: https://github.com/mperham/dalli/issues/250
      Marshal.dump(result)
      
      # Store the result in cache.
      result
    end
  end
  
  def invalidate_cache
    # Be careful in specs. This takes one second to count as invalid.
    self.touch
  end
  
  def delete_cached(method_name)
    invalidate_cache
    #Rails.cache.delete_matched "#{self.class.table_name}/#{id}/#{method_name}"
  end
  
  def delete_cache
    invalidate_cache
    #Rails.cache.delete_matched "#{self.class.table_name}/#{id}/*"
  end
  
  def cache_created_at(method_name)
    #CacheAdditions
    Rails.cache.created_at [self, method_name, arguments]
  end
  
  module ClassMethods
  end
end