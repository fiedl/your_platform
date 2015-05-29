class IssuesController < ApplicationController

  before_action :load_issues
  
  def index
    authorize! :index, Issue
    redirect_to issues_path if params[:rescan].present?
    
    set_current_title :administrative_issues
    set_current_activity :solves_administrative_issues
  end
  
  private
  
  def load_issues
    @issues = current_issues
    if params[:rescan] == 'all'
      Issue.scan
      @issues = current_issues
    end
    if params[:rescan] == 'mine'
      objects = Issue.by_admin(current_user).collect { |issue| issue.reference }
      Issue.scan_objects(objects)
      @issues = current_issues
    end
  end

end