concern :GroupCaching do

  # Make sure this concern is included at the bottom of the class.
  # Otherwise, the methods to be cached are not declared, yet.
  #
  included do
    after_save { self.delay.renew_cache }

    cache :corporation_id
    cache :leaf_group_ids

    cache :group_of_groups?
    cache :name_with_corporation

    # GroupMemberships
    cache :membership_ids_for_member_list
    cache :memberships_for_member_list_count
    cache :latest_memberships
    cache :memberships_this_year

    # GroupMemberList
    cache :member_table_rows
  end

  include StructureableRoleCaching
end