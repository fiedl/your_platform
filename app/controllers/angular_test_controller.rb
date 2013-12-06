class AngularTestController < ApplicationController

  # before_filter :find_and_authorize_profileable
  # 
  # def index
  #   @profileable ||= current_user
  #   @profile_fields = @profileable.profile_fields if @profileable
  # end
  # 
  # private
  # 
  # def find_and_authorize_profileable
  #   if params[ :profileable_type ] && params[ :profileable_id ]
  #     @profileable = params[ :profileable_type ].constantize.find( params[ :profileable_id ] )
  #   end
  #   authorize! :update, @profileable
  # end

end
