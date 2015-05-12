class ActivitiesController < ApplicationController
  skip_authorization_check only: :index
  
  def index
    authorize! :index, PublicActivity::Activity
    
    @activities = PublicActivity::Activity
    @activities = @activities.where(owner: current_user.administrated_objects.select { |o| o.kind_of?(User) }) unless Role.of(current_user).global_admin?
    @activities = @activities.order('created_at desc').limit(100)
    
    @title = t(:activity_log)
  end
end
