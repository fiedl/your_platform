module WorkflowKit
  class LastMembershipNeedsReviewBrick < Brick
    def name
      "Mark the last membership for review"
    end
    def description
      "The last membership of the user is marked with :needs_review. " +
        "The admins have to confirm the valid_from date of the membership."
    end
    def execute( params )
      raise RuntimeError, 'no user_id given' unless params[ :user_id ]

      user = User.find( params[ :user_id ] )
      membership = user.memberships.order('created_at').last

      membership.needs_review!
    end
  end
end
