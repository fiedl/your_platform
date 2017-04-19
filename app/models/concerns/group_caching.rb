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

    # GroupListExports
    cache :export_list
  end

  def fill_cache
    super

    # Using `fill_cached_method`, this is delegated to
    # its own background job.
    self.fill_cached_method :fill_cache_for_export_lists

    # Also renew the member's titles in separate
    # background jobs to avoid timeouts.
    self.members.each do |user|
      user.renew_cache_later method: :title
    end
  end

  def fill_cache_for_export_lists
    Group.export_list_presets.each do |preset|
      [:csv, :xls].each do |format|
        self.export_list preset: preset, format: format
      end
    end
  end

  include StructureableRoleCaching
end