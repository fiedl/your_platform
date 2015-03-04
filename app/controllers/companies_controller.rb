class CompaniesController < ApplicationController
  respond_to :html, :json
  
  before_filter :find_companies
  authorize_resource

  def index
    respond_to do |format|
      format.html { redirect_to Company.companies_parent }
      format.json { respond_with @companies.pluck(:name) }
    end
  end
  
  
  private
  
  def find_companies
    query = params[:term] || params[:query] || ""
    @companies = Company.where('name LIKE ?', "%#{query}%")
  end
  
end