module DecisionMaking

  # Decision making process, like a poll or a ballot.
  #
  # @!attribute title [String]
  # @!attribute wording [String]
  # @!attribute rationale [String]
  # @!attribute deadline [Time]
  # @!attribute proposed_at [Time]
  # @!attribute decided_at [Time]
  #
  class Process < ApplicationRecord
    belongs_to :creator_user, class_name: "User"
    belongs_to :proposer_group, class_name: "Group"
    belongs_to :scope_group, class_name: "Group"
    has_many :signatures, as: :signable, dependent: :destroy
    has_many :attachments, as: :parent, dependent: :destroy
    has_many :options, dependent: :destroy
    has_many :votes, dependent: :destroy

    def localized_proposed_at
      I18n.localize proposed_at.to_date
    end

    def localized_proposed_at=(date_string)
      begin
        self.proposed_at = date_string.to_date
      rescue
        self.proposed_at = nil
      end
    end

    def status_key
      :draft
    end

    def status_string
      I18n.t(:draft)
    end

  end
end