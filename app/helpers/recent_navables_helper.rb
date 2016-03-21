module RecentNavablesHelper
  
  def recent_navables
    @recent_navables ||= if current_user && current_navable
      add_current_navable_to_recent_navables
      cached_recent_navables - [current_navable]
    else
      []
    end
  end
  
  def add_current_navable_to_recent_navables
    add_to_recent_navables(current_navable) unless current_navable.in? cached_recent_navables
  end
  
  def add_to_recent_navables(navable)
    navables = cached_recent_navables + [navable]
    write_recent_navables_to_cache(navables)
    return navables
  end
  
  def cached_recent_navables
    (Rails.cache.read(recent_navables_cache_key) || []).last(10)
  end
  
  def write_recent_navables_to_cache(navables)
    Rails.cache.write recent_navables_cache_key, navables, expires_in: 1.hour
  end
  
  def recent_navables_cache_key
    [current_user, "recent_navables"]
  end
  
end