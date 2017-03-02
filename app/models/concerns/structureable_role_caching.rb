concern :StructureableRoleCaching do

  included do

    def self.structureable_role_methods_to_cache
      [
        :officers_of_self_and_parent_groups,
        :officers_groups_of_self_and_descendant_groups,
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

    self.structureable_role_methods_to_cache.each do |method|
      cache method
    end
  end

  def fill_cache
    super

    if kind_of?(OfficerGroup) && scope
      scope.descendants.each do |descendant|
        if descendant.respond_to? :fill_cache_concerning_roles
          descendant.fill_cache_concerning_roles
        end
      end
    end
  end

  def fill_cache_concerning_roles
    self.class.structureable_role_methods_to_cache.each do |method|
      self.send method
    end
  end

end