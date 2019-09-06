concern :UserDocuments do

  def documents_of_interest
    documents_in_my_scope.order(created_at: :desc).limit(10)
  end

  def documents_in_my_scope
    Attachment.where id: document_ids_in_my_scope
  end

  def document_ids_in_my_scope
    (self.news_pages + self.posts)
      .map(&:attachments).flatten
      .select { |attachment| attachment.document? }
      .map(&:id)
  end

end