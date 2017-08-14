class Structureables::SubEntries::ExistingGroupsController < Structureables::SubEntriesController

    expose :group

    def create
      authorize! :create_group_for, parent

      last_membership_id = Membership.last.id
      parent << group
      parent.delete_cached :nav_child_group_ids if Group.use_caching?
      Membership.where("id > ?", last_membership_id).indirect.each { |m| m.recalculate_validity_range }
      parent.delete_cache if Group.use_caching?

      redirect_to parent
    end

end