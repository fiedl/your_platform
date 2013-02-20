class StarsController < ApplicationController

  def update
    toggle
  end

  def toggle
    find_star
    if @star
      @star.destroy
    else
      Star.create( params_to_pass )
    end
  end

  private 

  def find_star
    user = User.find params[ :user_id ] if params[ :user_id ]
    if params[ :starrable_id ] and params[ :starrable_type ]
      starrable = params[ :starrable_type ].constantize.find params[ :starrable_id ] 
    end
    @star = Star.find_by_user_and_starrable( user, starrable ) if user and starrable
  end

  def params_to_pass
    { 
      user_id: params[ :user_id ], 
      starrable_id: params[ :starrable_id ],
      starrable_type: params[ :starrable_type ]
    }
  end

end
