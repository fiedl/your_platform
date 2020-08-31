concern :UserDocuments do

  def documents_of_interest(limit: 10)
    documents_in_my_scope.order(created_at: :desc).limit(limit)
  end

  def documents_in_my_scope
    documents_in_my_posts.or(documents_in_my_pages)
  end

  def documents_in_my_posts
    Attachment.documents.where(parent_type: "Post", parent_id: self.posts.published)
  end

  def documents_in_my_pages
    Attachment.documents.where(parent_type: "Page", parent_id: self.news_pages)
  end

end