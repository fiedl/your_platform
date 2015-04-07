class CorporationsController < ApplicationController
  respond_to :html, :json
  
  before_action :find_corporations
  authorize_resource

  def index
    respond_to do |format|
      format.html { redirect_to Corporation.corporations_parent }
      format.json { respond_with @corporations.pluck(:name) }
    end
  end
  
  
  private
  
  def find_corporations
    query = params[:term] || params[:query] || ""
    @corporations = Corporation.where('name LIKE ?', "%#{query}%")
  end
  
end