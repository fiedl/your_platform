# -*- coding: utf-8 -*-

# This extends the your_platform UserGroupMembership model.
require_dependency YourPlatform::Engine.root.join( 'app/models/user_group_membership' ).to_s

# This class represents a UserGroupMembership of the platform.
#
class UserGroupMembership
  # Override the flush_cache_ugm method in order to delete specific cache
  #
  alias_method :orig_flush_cache_ugm, :flush_cache_ugm
  def flush_cache_ugm
    Rails.cache.delete([self.user, "aktivitaetszahl"])
    orig_flush_cache_ugm
  end

end

