class PagesController < ApplicationController

  before_filter :find_page, only: [:show, :update]
  respond_to :html, :json

  def show
    if @page
      redirect_to @page.redirect_to if @page.redirect_to
      
      @title = @page.title
      @navable = @page
    end
  end

  def update
    @page.update_attributes params[ :page ]
    respond_with @page
  end

  def create
    if params[:parent_type].present? && params[:parent_id].present?
      @parent = params[:parent_type].constantize.find(params[:parent_id]).child_pages
    else
      @parent = Page
    end
    @new_page = @parent.create( title: I18n.t(:new_page) )
    redirect_to @new_page
  end


  private

  def find_page
    @page = Page.find params[ :id ]
  end
end
