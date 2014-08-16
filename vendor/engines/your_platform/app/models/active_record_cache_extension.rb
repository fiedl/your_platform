module ActiveRecordCacheExtension
  extend ActiveSupport::Concern
  
  def cached(method_name)
    #require 'pry'; binding.pry
    Rails.cache.fetch([self.class.table_name, id, method_name], expire_in: 1.week) do 
      result = send(method_name)
      Marshal.dump(result) # This circumvents a bug: https://github.com/mperham/dalli/issues/250
      result
    end
    #convert_ids_of_cached_relation(Rails.cache.fetch([self.class.table_name, id, method_name], expire_in: 1.week) do
    #  convert_ids_of_uncached_relation(send(method_name))
    #end)
  end
  
  def delete_cached(method_name)
    #Rails.cache.delete_matched "#{self.class.table_name}*#{id}*#{method_name}*" if id
  end
  
  def delete_cache
    #Rails.cache.delete_matched "#{self.class.table_name}*#{id}*" if id
  end
  
  def cache_created_at(method_name, args)
    #CacheAdditions
    #Rails.cache.created_at [self.class.table_name, id, method_name, **args]
  end
  
  private

  # THIS CONVERSION IS CRAP:
  # Noone can know that the ids belong to this class (self)!

  #def convert_ids_of_cached_relation(relation)
  #  p "CONVERT 1"
  #  if relation.kind_of?(Array) && relation.first.kind_of?(Integer)
  #    self.class.unscoped.find relation
  #  else
  #    relation
  #  end
  #end
  #def convert_ids_of_uncached_relation(relation)
  #  p "CONVERT 2"
  #  p relation.class.name
  #  p relation.kind_of? ActiveRecord::Relation
  #  p relation if relation.kind_of?(Array)
  #  
  #  if relation.kind_of? ActiveRecord::Relation
  #    p relation.pluck(:id)
  #    relation.pluck(:id)
  #  else
  #    relation
  #  end
  #end
  
  module ClassMethods
  end
end