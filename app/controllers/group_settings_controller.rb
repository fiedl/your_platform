class GroupSettingsController < ApplicationController
  skip_authorize_resource :only => :index
  
  def index
    @group = Group.find params[:group_id]
    authorize! :manage, @group
    
    point_navigation_to @group
    @title = "#{t(:group_settings)}: #{@group.name}"
    
    cookies[:group_tab] = "settings"
    current_user.try(:update_last_seen_activity, "#{t(:manages_group_settings)}: #{@group.title}", @group)
  end
  
end