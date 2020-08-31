concern :PostDrafts do

  included do
    scope :draft, -> { where(sent_at: nil, published_at: nil) }
    scope :published, -> { where.not(id: draft) }
  end

  def draft?
    sent_at.nil? && published_at.nil?
  end

end