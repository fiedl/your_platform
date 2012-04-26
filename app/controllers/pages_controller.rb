class PagesController < ApplicationController
  def show
    @page = Page.find_by_id( params[ :id ] ) if params[ :id ]
    if @page
      @title = @page.title
      @navable = @page
    end
  end
end
