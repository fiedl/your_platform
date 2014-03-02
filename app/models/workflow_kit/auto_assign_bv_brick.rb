module WorkflowKit
  class AutoAssignBvBrick < Brick
    def name
      "Auto Assign BV"
    end
    def description
      "Auto assign the user to the appropriate BV if the user is a philister."
    end
    def execute( params )
      raise 'no user_id given' unless params[ :user_id ] 
      user = User.find( params[ :user_id ] )  
      user.adapt_bv_to_postal_address
    end
  end
end