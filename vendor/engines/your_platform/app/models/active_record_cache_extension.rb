module ActiveRecordCacheExtension
  extend ActiveSupport::Concern
  
  def cached(method_name)
    Rails.cache.fetch([self.class.table_name, id, method_name], expire_in: 1.week) do 
      result = send(method_name)
      Marshal.dump(result) # This circumvents a bug: https://github.com/mperham/dalli/issues/250
      result
    end
  end
  
  def delete_cached(method_name)
    Rails.cache.delete_matched "#{self.class.table_name}/#{id}/#{method_name}/*"
  end
  
  def delete_cache
    Rails.cache.delete_matched "#{self.class.table_name}/#{id}/*"
  end
  
  def cache_created_at(method_name)
    CacheAdditions
    Rails.cache.created_at [self.class.table_name, id, method_name]
  end
  
  module ClassMethods
  end
end