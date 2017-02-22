concern :StructureableRoleCaching do

  included do
    cache :officers_of_self_and_parent_groups
    cache :officers_groups_of_self_and_descendant_groups
    cache :find_officers
    cache :officers_of_ancestors
    cache :officers_of_ancestor_groups
    cache :officers_of_self_and_ancestors
    cache :officers_of_self_and_ancestor_groups
    cache :find_admins
    cache :admins_of_ancestors
    cache :admins_of_ancestor_groups
    cache :admins_of_self_and_ancestors
    cache :local_admins
    cache :responsible_admins
  end

  def delete_cache
    super
    delete_caches_concerning_roles
  end

  def delete_caches_concerning_roles
    if self.class.base_class.name == 'Group'
      # For an admins_parent, this is called recursively until the original group
      # is reached.
      #
      #   group
      #     |---- officers_parent
      #                |------------ admins_parent
      #                |------------ some officer group
      #
      if has_flag?(:officers_parent) || has_flag?(:admins_parent)
        parent_groups.each do |group|
          group.delete_cache
          if group.descendants.count > 0
            bulk_delete_cached :admins_of_ancestors, group.descendants
            bulk_delete_cached :admins_of_self_and_ancestors, group.descendants
            bulk_delete_cached "*officers*", group.descendants
          end
        end
      end
    end
  end

end