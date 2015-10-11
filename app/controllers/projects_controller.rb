class ProjectsController < ApplicationController
  load_and_authorize_resource
  
  def index
    if @group
      @projects = @group.child_projects
      set_current_title t(:projects_of_str, str: @group.name)
      set_current_navable @group
    else
      @projects = current_user.groups.collect { |g| g.child_projects }.flatten
      set_current_title t(:my_projects)
      set_current_navable current_user
    end 
  end
  
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
  
  def new
    set_current_title t(:new_project)
    set_current_navable Page.find_intranet_root
    
    @project = Project.new
  end
  
  def create
    @project = Project.new(project_params)
    @project.title ||= I18n.t(:new_project)
    @project.save!
    
    if current_user.corporation && @project.group.try(:corporation) != current_user.corporation
      current_user.corporation << @project
    end
    
    redirect_to @project
  end
  
  private
  
  def project_params
    params.require(:project).permit(:title, :description, :corporation_name)
  end
  
end