require 'colored'
require 'cache_additions'
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
    self.cached_at ||= Time.zone.now
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
      if Rails.cache.created_at([self.cache_key, key]).nil? || Rails.cache.created_at([self.cache_key, key]) < self.cached_at
        result = process_result_for_caching(yield)
        Rails.cache.write [self.cache_key, key], result, expires_in: 1.week
        result
      else
        Rails.cache.read [self.cache_key, key]
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

  def renew_cached(method_name)
    self.delete_cached method_name
    self.send method_name
  end

  def bulk_delete_cached(method_name, objects)
    ids = objects.map &:id
    regex = /.*\/(#{ids.join('|')})(-.*|)\/#{method_name}.*/
    # p "DEBUG BULK DELETE CACHE #{regex}"
    Rails.cache.delete_regex regex
  end

  def delete_cache
    # print "DEBUG DELETE CACHE #{self}\n".red.bold
    Rails.cache.delete_matched "#{self.cache_key}/*"
  end

  def renew_cache
    self.cached_at = Time.zone.now
    fill_cache
  end

  def fill_cache
    self.class.cached_methods.try(:each) do |method_name|
      #print "-> Filling cached :#{method_name}\n"
      self.send method_name
    end
  end

  def cache_created_at(method_name, arguments = nil)
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

  def cached_at
    Rails.cache.read [self.cache_key, 'cached_at']
  end
  def cached_at=(datetime)
    Rails.cache.write [self.cache_key, 'cached_at'], datetime
  end

  module ClassMethods
    attr_accessor :cached_methods

    def cache(method_name)
      cache_method method_name
    end

    def cache_method(method_name)
      alias_method "uncached_#{method_name}", method_name

      define_method(method_name) {
        cached_block(method_name: method_name) { self.send "uncached_#{method_name}" }
      }

      self.cached_methods ||= []
      self.cached_methods << method_name
    end

  end
end