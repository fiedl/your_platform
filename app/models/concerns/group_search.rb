concern :GroupSearch do
  include StructureableSearch

  included do
    attr_accessor :search_hint
  end

  class_methods do

    def search(query, limit: 10000, current_user: nil)
      if current_user
        result = search_in_my_groups(query, user: current_user)
        result = search_in_my_corporations(query, user: current_user) unless result.present?
      end
      result = search_by_name(query) unless result.present?
      if current_user
        result = search_in_my_groups(query, user: current_user, include_ancestors: true) unless result.present?
        result = search_in_my_corporations(query, user: current_user, include_ancestors: true) unless result.present?
      end
      result = search_by_name(query, include_ancestors: true) unless result.present?
      result = (search_by_name(query).limit(limit) + search_by_breadcrumbs(query, limit: limit) + search_by_profile_fields(query)) unless result.present?
      self.where(id: result).regular.uniq.limit(limit)
    end

    def search_in_my_groups(query, user:, include_ancestors: false)
      search_by_name(query, include_ancestors: include_ancestors).where(id: user.groups)
    end

    def search_in_my_corporations(query, user:, include_ancestors: false)
      search_by_name(query, include_ancestors: include_ancestors).where(id: user.corporations.map(&:descendant_group_ids).flatten)
    end

    private

    def search_by_name(query, include_ancestors: false)
      if include_ancestors
        search_by_name_with_ancestors(query)
      else
        search_by_name_without_ancestors(query)
      end
    end

    def search_by_name_with_ancestors(query)
      relation = joins(:ancestor_groups)
      query.split(" ").each do |expression|
        relation = relation.where("groups.name LIKE ? OR groups.extensive_name LIKE ? OR ancestor_groups_groups.name LIKE ?", "%#{expression}%", "%#{expression}%", "%#{expression}%")
      end
      relation.uniq
    end

    def search_by_name_without_ancestors(query)
      relation = self
      query.split(" ").each do |expression|
        relation = relation.where("groups.name LIKE ? OR groups.extensive_name LIKE ?", "%#{expression}%", "%#{expression}%")
      end
      relation.uniq
    end

    def search_by_extensive_name(query)
      where("extensive_name LIKE ?", "%#{query}%")
    end

    def search_by_profile_fields(query)
      q = "%" + query.gsub(' ', '%') + "%"
      profile_fields =
        ProfileField.where(profileable_type: "Group").where("value like ? or label like ?", q, q) +
        ProfileField.joins(:parent).where(parents_profile_fields: {profileable_type: "Group"}).where("profile_fields.value like ? or profile_fields.label like ?", q, q)
      groups = profile_fields.collect do |profile_field|
        group = profile_field.profileable
        group.search_hint = "#{profile_field.label}: #{profile_field.value}"
        group
      end
    end

  end
end