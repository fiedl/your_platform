# -*- coding: utf-8 -*-

# This extends the your_platform UserGroupMembership model.
require_dependency YourPlatform::Engine.root.join( 'app/models/user_group_membership' ).to_s

# This class represents a UserGroupMembership of the platform.
#
class UserGroupMembership

  # This method is called by a nightly rake task to renew the cache of this object.
  #
  def fill_cache
    cached(:valid_from)
  end

end

