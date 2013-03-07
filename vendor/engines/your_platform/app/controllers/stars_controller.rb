class StarsController < ApplicationController

  respond_to :json

  def index
#    @stars = find_stars
    respond_with find_stars
#    respond_to do |format|
#      format.json { respond_with @stars }
#      format.html
#    end
  end

  def create
    respond_with Star.create( params[ :star ] )
  end

  def destroy
    respond_with Star.find( params[ :id ] ).destroy
  end

  private 

  def find_stars
    user = User.find params[ :user_id ] if params[ :user_id ].present?
    Star.find_all_by_user( user ) if user
  end

end
