concern :PostDrafts do

  included do
    scope :draft, -> { where(sent_at: nil, published_at: nil) }
    scope :archived, -> { where.not(archived_at: nil) }
    scope :not_published, -> { where(id: draft).or(where(id: archived)) }
    scope :published, -> { where.not(id: not_published) }
  end

  def draft?
    sent_at.nil? && published_at.nil?
  end

end