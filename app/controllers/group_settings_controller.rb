class GroupSettingsController < ApplicationController
  skip_authorize_resource :only => :index
  
  def index
    @group = Group.find params[:group_id]
    authorize! :manage, @group
    
    set_current_navable @group
    set_current_title "#{t(:group_settings)}: #{@group.name}"
    set_current_activity :manages_group_settings, @group
    
    cookies[:group_tab] = "settings"
  end
  
end