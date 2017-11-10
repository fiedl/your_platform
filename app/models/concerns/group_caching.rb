concern :GroupCaching do

  # Make sure this concern is included at the bottom of the class.
  # Otherwise, the methods to be cached are not declared, yet.
  #
  included do
    after_save { self.renew_cache_later }

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

    # GroupMapItem
    cache :map_item

    # GroupSearch
    cache :breadcrumb_titles
  end

  def fill_cache
    super

    self.fill_cache_for_export_lists
  end

  def fill_cache_for_export_lists
    Sidekiq::Logging.logger.info "#{self.title} # fill_cache_for_export_lists" if Sidekiq::Logging.logger && (! Rails.env.test?)

    Group.export_list_presets.each do |preset|
      [:csv, :xls].each do |format|
        self.export_list preset: preset, format: format
      end
    end
  end

  include StructureableRoleCaching
end