module DecisionMaking

  # Decision making process, like a poll or a ballot.
  #
  # @!attribute title [String]
  # @!attribute wording [String]
  # @!attribute rationale [String]
  # @!attribute opened_for_voting [Time]
  # @!attribute deadline [Time]
  # @!attribute proposed_at [Time]
  # @!attribute decided_at [Time]
  # @!attribute required_majority [String] one of the following: "1/2", "2/3", "3/4"
  #
  class Process < ApplicationRecord
    belongs_to :creator_user, class_name: "User"
    belongs_to :proposer_group, class_name: "Group"
    belongs_to :scope_group, class_name: "Group"
    has_many :signatures, as: :signable, dependent: :destroy
    has_many :attachments, as: :parent, dependent: :destroy
    has_many :options, dependent: :destroy
    has_many :votes, dependent: :destroy

    scope :published, -> { where.not(opened_for_voting_at: nil) }
    scope :for_approval, -> (current_user) {
      if current_user.in? global_officers_that_can_approve_proposal
        where.not(proposed_at: nil).where(opened_for_voting_at: nil)
      else
        []
      end
    }
    scope :my_drafts, -> (current_user) {
      where(creator_user_id: current_user.id) +
      where(id: DecisionMaking::Signature.where(user_id: current_user.id).pluck(:signable_id))
    }


    def localized_proposed_at
      I18n.localize proposed_at.to_date if proposed_at
    end

    def localized_proposed_at=(date_string)
      begin
        self.proposed_at = date_string.to_date
      rescue
        self.proposed_at = nil
      end
    end

    def localized_deadline
      I18n.localize deadline.to_date if deadline
    end

    def localized_deadline=(date_string)
      begin
        self.deadline = date_string.to_date
      rescue
        self.deadline = nil
      end
    end

    def status_key
      :draft
    end

    def status_string
      I18n.t("decision_making_status_#{status_key}")
    end

    def ready_for_submission?
      title.present? && wording.present? && rationale.present? && signed? && !submitted?
    end

    def draft?
      not submitted?
    end

    def signed?
      signatures.any?
    end

    def submitted?
      proposed_at.present?
    end

    def waiting_for_approval?
      submitted? && !open_for_voting?
    end

    def decided?
      decided_at.present?
    end

    def open_for_voting?
      opened_for_voting_at.present?
    end

    def notify_global_officers_about_new_proposal(options = {})
      current_user = options[:current_user] || raise(RuntimeError, 'option current_user missing')
      self.class.global_officers_that_can_approve_proposal.each do |recipient|
        Notification.create(
          recipient_id: recipient.id,
          author_id: current_user.id,
          reference_url: self.url,
          reference_type: self.class.to_s,
          reference_id: self.id,
          message: self.title,
          text: I18n.t(:str_has_submitted_a_new_ballot, str: proposer_group.title)
        )
      end
    end

    def self.global_officers_that_can_approve_proposal
      Role.global_officers
    end

  end
end