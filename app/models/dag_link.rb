class DagLink < ApplicationRecord

  belongs_to :ancestor, polymorphic: true
  belongs_to :descendant, polymorphic: true

  scope :direct, -> { where(direct: true) }
  scope :indirect, -> { where(direct: false) }
  scope :now, -> { p "TODO: #now"; all }

  include DagLinkGraph
  include DagLinkTypes

  after_commit -> { RecreateIndirectDagLinksJob.perform_later(descendant.id) if direct and descendant_type == "User" }

end
