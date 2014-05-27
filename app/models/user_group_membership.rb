# -*- coding: utf-8 -*-

# This extends the your_platform UserGroupMembership model.
require_dependency YourPlatform::Engine.root.join( 'app/models/user_group_membership' ).to_s

# This class represents a UserGroupMembership of the platform.
#
class UserGroupMembership
  alias_method :orig_delete_cache_usergroupmembership, :delete_cache_usergroupmembership
  def delete_cache_usergroupmembership
    orig_delete_cache_usergroupmembership
  end

end

