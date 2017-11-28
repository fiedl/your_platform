concern :PageSearch do
  include StructureableSearch

  class_methods do

    def search(query, options = {})
      limit = options[:limit] || 10000
      (search_by_title(query).limit(limit) + search_by_breadcrumbs(query, limit: limit, base_class: Page, search_attribute: :title)).uniq.first(limit)
    end

    private

    def search_by_title(query)
      where("title LIKE ?", "%#{query}%")
    end

  end
end