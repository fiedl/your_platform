concern :UserSearch do
  included do
    attr_accessor :search_hint
  end

  class_methods do

    def search(query)
      if query.present?
        search_by_geo_location(query) || (search_by_name_and_title(query) + search_by_profile_fields(query))
      else
        []
      end.uniq
    end

    private

    def search_by_geo_location(query)
      if match_data = query.match(/(.*) ([0-9]*)km/)
        address = match_data[1]
        radius = match_data[2]
        users = User.within radius_in_km: radius, around: address
        users.select do |user|
          user.alive? && user.wingolfit?
        end
      end
    end

    def search_by_name_and_title(query)
      q = "%" + query.gsub(' ', '%') + "%"
      users = self
        .where("CONCAT(first_name, ' ', last_name) LIKE ?", q)
        .order('last_name', 'first_name').distinct
      users = [User.find_by_title(query)] - [nil] if users.none?
      users
    end

    def search_by_profile_fields(query)
      q = "%" + query.gsub(' ', '%') + "%"
      profile_fields =
        ProfileField.where(profileable_type: "User").where("value like ? or label like ?", q, q) +
        ProfileField.joins(:parent).where(parents_profile_fields: {profileable_type: "User"}).where("profile_fields.value like ? or profile_fields.label like ?", q, q)
      users = profile_fields.collect do |profile_field|
        user = profile_field.profileable
        user.search_hint = "#{profile_field.label}: #{profile_field.value}"
        user
      end
    end

  end
end