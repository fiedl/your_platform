class IssuesController < ApplicationController
  respond_to :html, :json

  before_action :load_issues, only: :index
  load_and_authorize_resource

  def index
    authorize! :index, Issue
    redirect_to issues_path if params[:rescan].present?

    set_current_title t(:administrative_issues)
    set_current_activity :solves_administrative_issues
  end

  def show
    @issue = Issue.find params[:id]
  end

  def new
    set_current_title t(:report_new_issue)
  end

  def create
    if params[:invalid_email].present?
      email_field = ProfileFieldTypes::Email.where(value: params[:invalid_email]).first
      if email_field
        email_field.needs_review!
        issue = Issue.scan_object(email_field).first
        issue.description = params[:description] if params[:description].present?
        issue.author = current_user
        issue.save
        redirect_to issue
      else
        redirect_to :back
      end
    end
  end

  def destroy
    @issue.reference.try(:remove_flag, :needs_review)
    if @issue.author
      # If this report was manually reported by an author,
      # we do not delete it, but keep it for future reference.
      # Just mark as `resolved`.
      #
      @issue.resolve
    else
      @issue.destroy!
    end
    head :ok
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