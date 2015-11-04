# This patches the basic Array object.
#
class Array
  
  # Pass the `reload` to all objects in the array
  # if they respond to `reload`.
  #
  # This is used in model caching.
  # See, for exmaple, `app/models/cache_store_extension.rb`.
  #
  def reload
    collect { |element| element.reload if element.respond_to?(:reload) }
  end
  
  def pluck(attr_name)
    map(&attr_name)
  end
  
end