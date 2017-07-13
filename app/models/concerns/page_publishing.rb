concern :PagePublishing do

  included do
    scope :published, -> { where('published_at <= ?', Time.zone.now) }
  end

  def published?
    self.in? Page.all.published
  end

  def unpublished?
    not published?
  end

  def draft?
    unpublished?
  end

end