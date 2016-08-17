concern :UserSearch do
  class_methods do

    def search(query)
      q = "%" + query.gsub(' ', '%') + "%"
      users = self
        .where("CONCAT(first_name, ' ', last_name) LIKE ?", q)
        .order('last_name', 'first_name')
      users = [User.find_by_title(query)] - [nil] if users.none?
      users.uniq
    end

  end
end