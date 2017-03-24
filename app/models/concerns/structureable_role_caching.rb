concern :StructureableRoleCaching do

  included do

    def self.structureable_role_methods_depending_on_ancestors
      [
        :officers_of_self_and_parent_groups,
        :find_officers,
        :officers_of_ancestors,
        :officers_of_ancestor_groups,
        :officers_of_self_and_ancestors,
        :officers_of_self_and_ancestor_groups,
        :find_admins,
        :admins_of_ancestors,
        :admins_of_ancestor_groups,
        :admins_of_self_and_ancestors,
        :local_admins,
        :responsible_admins
      ]
    end

    def self.structureable_role_methods_depending_on_descendants
      [
        :officers_groups_of_self_and_descendant_groups
      ]
    end

    def self.structureable_role_methods_to_cache
      structureable_role_methods_depending_on_ancestors +
      structureable_role_methods_depending_on_descendants
    end

    self.structureable_role_methods_to_cache.each do |method|
      cache method
    end
  end

  def fill_cache
    super

    if kind_of?(OfficerGroup) && scope
      scope.fill_cache_concerning_roles_for(self.class.structureable_role_methods_to_cache) if scope.respond_to?(:fill_cache_concerning_roles_for)

      scope.descendants.each do |descendant|
        descendant.fill_cache_concerning_roles_for(self.class.structureable_role_methods_depending_on_ancestors) if descendant.respond_to?(:fill_cache_concerning_roles_for)
      end

      scope.ancestors.each do |ancestor|
        ancestor.fill_cache_concerning_roles_for(self.class.structureable_role_methods_depending_on_descendants) if ancestor.respond_to?(:fill_cache_concerning_roles_for)
      end
    end
  end

  def fill_cache_concerning_roles_for(methods)
    methods.each do |method|
      self.send method
    end
  end

end