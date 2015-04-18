class VerticalNavsController < ApplicationController
  before_action :find_and_authorize_navable
  layout false
  
  def show
  end
  
  private
  
  def find_and_authorize_navable
    @navable = find_navable
    authorize! :read, @navable
  end
  
  def find_navable
    @navable = case params[:navable_type]
    when 'Group'
      Group.find params[:navable_id]
    when 'Page'
      Page.find params[:navable_id]
    when 'User'
      User.find params[:navable_id]
    when 'Event'
      User.find params[:navable_id]
    end
  end
end