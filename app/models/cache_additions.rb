module CacheAdditions
  def entry(name)
    options = merged_options(nil)
    key = namespaced_key(name, options)
    read_entry(key, options)
  end

  # This method reveals when a cache entry has been created.
  #
  def created_at(name)
    Time.at(entry(name).created_at) if entry(name)
  end
end

ActiveSupport::Cache::Store.include(CacheAdditions)

class ActiveSupport::Cache::Entry
  def created_at
    Time.at(@created_at)
  end
end