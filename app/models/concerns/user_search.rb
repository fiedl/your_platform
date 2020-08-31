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
      end.to_a.uniq
    end

    def search_by_geo_location(query)
      if match_data = query.match(/(.*) ([0-9]*)km/)
        address = match_data[1]
        radius = match_data[2]
        users = self.alive.within(radius_in_km: radius, around: address)
      end
    end

    def search_by_name_and_title(query)
      q = "%" + query.gsub(' ', '%') + "%"
      users = self.where(id: User
        .where("CONCAT(users.first_name, ' ', users.last_name) LIKE ?", q)
        .order('users.last_name', 'users.first_name').distinct
      )
      users = [User.find_by_title(query)] - [nil] if users.none?
      users
    end

    def search_by_profile_fields(query)
      profile_fields = ProfileField.where_like(value: query).or(
        ProfileField.where_like(label: query)
      )
      profile_fields.includes(:parent).to_a.collect do |profile_field|
        # When calling `profile_field.profileable` here, we get
        # ActiveRecord::StatementInvalid (Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ''Group'' at line 1
        if (profile_field.parent || profile_field).profileable_type == 'User'
          if self.exists? id: (profile_field.parent || profile_field).profileable_id
            if user = User.find((profile_field.parent || profile_field).profileable_id)
              user.search_hint = "#{profile_field.label}: #{profile_field.value}"
              user
            end
          end
        end
      end - [nil]
    end

  end
end