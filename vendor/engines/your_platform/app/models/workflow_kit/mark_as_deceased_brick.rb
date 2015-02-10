module WorkflowKit
  class MarkAsDeceasedBrick < Brick
    def name
      "Mark User as Deceased"
    end
    def description
      "Move the user to the deceased status in all his corporations. Remove other group memberships. Set the date-of-death profile field. Deactivate user account."
    end
    def execute( params )
      raise 'no user_id given' unless params[:user_id] 
      raise 'no localized_date_of_death given' unless params[:localized_date_of_death]
      user = User.find(params[:user_id])
      date_of_death = params[:localized_date_of_death].to_date
      user.mark_as_deceased at: date_of_death
    end
  end
end