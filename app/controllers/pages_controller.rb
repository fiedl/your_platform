class PagesController < ApplicationController

  before_filter :find_page
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

  private

  def find_page
    @page = Page.find params[ :id ]
  end
end
