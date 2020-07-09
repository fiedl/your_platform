concern :GroupSearch do
  include StructureableSearch

  included do
    attr_accessor :search_hint
  end

  class_methods do

    def search(query, options = {})
      limit = options[:limit] || 10000
      (search_by_name(query).limit(limit) + search_by_breadcrumbs(query, limit: limit) + search_by_profile_fields(query)).uniq.first(limit)
    end

    private

    def search_by_name(query)
      where("name LIKE ?", "%#{query}%")
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