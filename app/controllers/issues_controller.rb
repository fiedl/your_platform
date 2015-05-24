class IssuesController < ApplicationController

  before_action :load_issues
  
  def index
    authorize! :index, Issue
    redirect_to issues_path if params[:rescan].present?
  end
  
  private
  
  def load_issues
    @issues = current_issues
    if @issues.count == 0 or params[:rescan] == 'all'
      Issue.scan
      @issues = current_issues
    end
  end

end