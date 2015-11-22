class GroupSettingsController < ApplicationController
  skip_authorize_resource :only => :index
  
  def index
    @group = Group.find params[:group_id]
    authorize! :update, @group
    
    set_current_navable @group
    set_current_title "#{t(:group_settings)}: #{@group.name}"
    set_current_activity :manages_group_settings, @group
    set_current_access :admin
    set_current_access_text I18n.t(:admins_of_group_name_can_read_this, group_name: @group.name)
    
    
    cookies[:group_tab] = "settings"
  end
  
end