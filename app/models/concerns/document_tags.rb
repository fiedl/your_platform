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
      matching_parent_pages = Page.where("title like ?", "%#{categories.join('%')}%").pluck(:id)
      matching_parent_pages_descendants = Page.where("title like ?", "%#{categories.join('%')}%").map(&:descendant_page_ids).flatten
      tagged(categories) +
      where("title like ?", "%#{categories.join('%')}%") +
      where(parent_type: 'Page', parent_id: matching_parent_pages + matching_parent_pages_descendants)
    end
  end

end