# -*- coding: utf-8 -*-

# This extends the your_platform UserGroupMembership model.
require_dependency YourPlatform::Engine.root.join( 'app/models/user_group_membership' ).to_s

# This class represents a UserGroupMembership of the platform.
#
class UserGroupMembership
  alias_method :orig_flush_cache, :flush_cache

  def flush_cache
    orig_flush_cache
    Rails.cache.delete([self.user, "aktivitaetszahl"])
  end

end

