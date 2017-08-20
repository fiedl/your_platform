module WorkflowKit
  class DestroyAccountAndEndMembershipsIfNeededBrick < Brick
    def name
      "Destroy UserAccount and end all non-corporation memberships if needed."
    end
    def description
      "If the user is not member of any corporation anymore: Destroy the associated UserAccount. This prevents login but keeps all user data. End all non-corporation memberships."
    end
    def execute( params )
      raise RuntimeError, 'no user_id given' unless params[ :user_id ]
      user = User.find( params[ :user_id ] )

      if user.current_corporations.count == 0
        user.account.try(:destroy)
        user.end_all_non_corporation_memberships
      end
    end
  end
end
