concern :DocumentTags do
  included do
    acts_as_taggable_on :tags

    scope :tagged, -> (tag) { tagged_with(tag) }
  end

  def add_tag(tag)
    tag_list.add tag
  end

  class_methods do
    def by_categories(categories)
      categories = categories.collect { |category| [category.singularize, category.pluralize] }.flatten
      matching_pages = Page.where_like title: categories
      matching_documents = self.where_like title: categories
      matching_documents.or(where(parent_type: 'Page', parent_id: matching_pages.collect { |page| [page.id] + page.descendant_page_ids}.flatten))
    end
  end

end