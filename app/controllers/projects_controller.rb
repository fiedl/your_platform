class ProjectsController < ApplicationController
  load_and_authorize_resource
  
  def show
    set_current_title @project.title
    set_current_navable @project
    set_current_activity :is_working_on_project, @project
    set_current_access :group
    set_current_access_text I18n.t(:members_of_group_name_can_read_this_content, group_name: @project.group.name)
  end
  
  def update
    @project.update_attributes params[:project]
    respond_with_bip(@project)
  end
end