class DagLink < ApplicationRecord

  belongs_to :ancestor, polymorphic: true
  belongs_to :descendant, polymorphic: true

  scope :direct, -> { where(direct: true) }
  scope :now, -> { p "TODO: #now"; all }

  include DagLinkGraph
  include DagLinkTypes

end
