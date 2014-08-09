module ActiveRecordCacheExtension
  extend ActiveSupport::Concern
  
  module InstanceMethods
    
    def cached(method_name, args)
      Rails.cache.fetch([table_name, id, method_name, **args], expire_in: 1.week) { send(method_name(**args)) }
    end
    
    def delete_cached(method_name)
      Rails.cache.delete_matched "#{table_name}*#{id}*#{method_name}*"
    end
    
    def delete_cache
      Rails.cache.delete_matched "#{table_name}*#{id}*"
    end
    
    def cache_created_at(method_name, args)
      CacheAdditions
      Rails.cache.created_at [table_name, id, method_name, **args]
    end
    
  end
end