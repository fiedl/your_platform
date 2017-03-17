concern :GroupCaching do

  # Make sure this concern is included at the bottom of the class.
  # Otherwise, the methods to be cached are not declared, yet.
  #
  included do
    after_save { RenewCacheJob.perform_later(self, time: Time.zone.now) }

    cache :corporation_id
    cache :leaf_group_ids

    cache :group_of_groups?
    cache :name_with_corporation

    # GroupMemberships
    cache :membership_ids_for_member_list
    cache :memberships_for_member_list_count
    cache :latest_membership_ids
    cache :membership_ids_this_year

    # GroupMemberList
    cache :member_table_rows

    # GroupEvents
    cache :event_ids_of_self_and_subgroups
  end

  include StructureableRoleCaching
end