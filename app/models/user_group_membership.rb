# -*- coding: utf-8 -*-

# This extends the your_platform UserGroupMembership model.
require_dependency YourPlatform::Engine.root.join( 'app/models/user_group_membership' ).to_s

# This class represents a UserGroupMembership of the platform.
#
class UserGroupMembership
  # Override the flush_cache method in order to delete specific cache
  #
  alias_method :orig_flush_cache, :flush_cache
  def flush_cache
    Rails.cache.delete([self.user, "aktivitaetszahl"])
    orig_flush_cache
  end

end

