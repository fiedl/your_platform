concern :GroupSearch do
  include StructureableSearch

  class_methods do

    def search(query, options = {})
      limit = options[:limit] || 10000
      (search_by_name(query).limit(limit) + search_by_breadcrumbs(query, limit: limit)).uniq.first(limit)
    end

    private

    def search_by_name(query)
      where("name LIKE ?", "%#{query}%")
    end

    def search_by_extensive_name(query)
      where("extensive_name LIKE ?", "%#{query}%")
    end

  end
end