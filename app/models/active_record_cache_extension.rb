#
# To understand our caching conventions, have a look at our wiki page:
# https://github.com/fiedl/wingolfsplattform/wiki/Caching
# 
module ActiveRecordCacheExtension
  extend ActiveSupport::Concern
  
  # Case 1: Use it to call a cached method result.
  # 
  #     user.cached(:name)
  #
  # Case 2: Use it to call a cached method with arguments.
  # Use this with care, since there is a cache for each argument!
  #
  #     user.cached(:membership_in, group)
  #
  # Case 3: Use it with a block within a method definition.
  # This moves the responsibility to cache into the model itself.
  # 
  #     class User
  #       def name
  #         cached { "#{first_name} #{last_name}" }
  #       end
  #     end
  #     
  #     user.name  # already uses the cache!
  #
  def cached(method_name = nil, arguments = nil, &block)
    if method_name
      cached_method(method_name, arguments)
    else
      cached_block(&block)
    end
  end
  
  def cached_method(method_name, arguments = nil)
    cached_block(method_name: method_name, arguments: arguments) do
      arguments ? send(method_name, *arguments) : send(method_name)
    end
  end
  private :cached_method
  
  # options: 
  #   method_name
  #   arguments
  #
  def cached_block(options = {}, &block)
    # This gives the method name that called the #cached method.
    # See: http://www.ruby-doc.org/core-2.1.2/Kernel.html
    #
    if options[:method_name] && options[:arguments]
      key = [options[:method_name], options[:arguments]]
    elsif options[:method_name]
      key = options[:method_name]
    else
      caller_method_name = caller_locations(2,1)[0].label
      key = caller_method_name
    end
    rescue_from_too_big_to_marshal(block) do
      Rails.cache.fetch([self, key], expires_in: 1.week) do
        process_result_for_caching(yield)
      end
    end
  end
  private :cached_block
  
  def process_result_for_caching(result)
    # Not all ActiveRecord::Relation objects can be stored in cache.
    # Convert them to Arrays. Otherwise, this might raise an 'cannot dump' error.
    result = result.to_a if result.kind_of? ActiveRecord::Relation
    
    # This circumvents a bug: https://github.com/mperham/dalli/issues/250
    Marshal.dump(result)
    
    # Store the result in cache.
    return result
  end
  private :process_result_for_caching
  
  def rescue_from_too_big_to_marshal(block_without_caching, &block_with_caching)
    begin
      yield
    rescue ArgumentError, NameError => exc
      if exc.message.include? 'year too big to marshal'
        block_without_caching.call
      else
        raise exc
      end
    end
  end
  private :rescue_from_too_big_to_marshal
  
  
  def invalidate_cache
    # Be careful in specs. This takes one second to count as invalid.
    self.touch
  end
  
  def delete_cached(method_name)
    # p "DEBUG DELETE CACHED #{self} #{method_name}"
    Rails.cache.delete [self, method_name]
    Rails.cache.delete_matched "#{self.cache_key}/#{method_name}/*"
  end
  
  def bulk_delete_cached(method_name, objects)
    ids = objects.map &:id
    regex = /.*\/(#{ids.join('|')})(-.*|)\/#{method_name}.*/
    # p "DEBUG BULK DELETE CACHE #{regex}"
    Rails.cache.delete_regex regex
  end
  
  def delete_cache
    # p "DEBUG DELETE CACHE #{self}"
    Rails.cache.delete_matched "#{self.cache_key}/*"
  end
  
  def cache_created_at(method_name, arguments = nil)
    ::CacheAdditions
    Rails.cache.created_at [self, method_name, arguments]
  end
  
  # This method ensures that no app cache is used to produce the result.
  # If you call
  #
  #    user.uncached :title
  #
  # this calls `user.title` but makes sure, no app cache is used at all.
  # Note: This does not prevent the sql cache to be used.
  #
  # You could use this in specs:
  #
  #     user.cached(:title).should == user.uncached(:title)
  #
  # ## What about user.title?
  #
  # Usually, user.title returns the uncached version; but if cached methods
  # are used in the implementation of `User#title` then `user.title` does use these
  # caches. If you call `user.uncached(:title)`, all app caches are ignored.
  #
  def uncached(method_name, args = nil)
    Rails.cache.uncached do
      if args
        self.send method_name, *args
      else
        self.send method_name
      end
    end
  end
  
  module ClassMethods
  end
end