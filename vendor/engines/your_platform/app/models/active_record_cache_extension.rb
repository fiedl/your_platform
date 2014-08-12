module ActiveRecordCacheExtension
  extend ActiveSupport::Concern
    
  def cached(method_name, args)
    p [self.class.table_name, id, method_name, **args]
    Rails.cache.fetch([self.class.table_name, id, method_name, **args], expire_in: 1.week) { send(method_name(**args)) }
  end
  
  def delete_cached(method_name)
    p "DELETE #{self.class.table_name}*#{id}*#{method_name}*"
    Rails.cache.delete_matched "#{self.class.table_name}*#{id}*#{method_name}*"
  end
  
  def delete_cache
    Rails.cache.delete_matched "#{self.class.table_name}*#{id}*"
  end
  
  def cache_created_at(method_name, args)
    CacheAdditions
    Rails.cache.created_at [self.class.table_name, id, method_name, **args]
  end
    
  module ClassMethods    
  end
end