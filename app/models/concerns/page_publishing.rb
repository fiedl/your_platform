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

  def localized_published_at
    I18n.localize published_at.to_date if published_at
  end

  def localized_published_at=(date_string)
    begin
      self.published_at = date_string.to_date
    rescue
      self.published_at = nil
    end
  end
end