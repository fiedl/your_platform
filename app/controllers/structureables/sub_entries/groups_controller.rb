class Structureables::SubEntries::GroupsController < Structureables::SubEntriesController

    def create
      authorize! :create_group_for, parent

      new_group = parent.child_groups.create name: t(:new_group)
      parent.delete_cached :nav_child_group_ids if Group.use_caching?

      redirect_to parent
    end

end