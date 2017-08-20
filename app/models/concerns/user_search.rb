concern :UserSearch do
  class_methods do

    def search(query)
      search_by_geo_location(query) || search_by_name_and_title(query)
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

  end
end