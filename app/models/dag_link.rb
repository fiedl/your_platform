class DagLink < ApplicationRecord

  belongs_to :ancestor, polymorphic: true
  belongs_to :descendant, polymorphic: true

  scope :direct, -> { where(direct: true) }
  scope :indirect, -> { where(direct: false) }
  scope :now, -> { p "TODO: #now"; all }

  include DagLinkGraph
  include DagLinkTypes

  after_commit -> {
    if direct
      CreateIndirectDagLinksJob.perform_later(descendant.id) if descendant_type == "User"
      if descendant_type == "Group"
        descendant.descendant_user_ids.each { |user_id| CreateIndirectDagLinksJob.perform_later(user_id) }
      end
    end
  }

end
