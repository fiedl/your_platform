concern :DocumentTags do
  included do
    acts_as_taggable_on :tags

    scope :tagged, -> (tag) { tagged_with(tag) }
  end

  def add_tag(tag)
    tag_list.add tag
  end

end