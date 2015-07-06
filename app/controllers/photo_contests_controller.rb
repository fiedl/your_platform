class PhotoContestsController < ApplicationController
  
  def show
    @page = Page.find params[:page_id]
    authorize! :read, @page
    
    @photo = @page.image_attachments.first
    
    set_current_navable @page
    set_current_title @page.title
  end
  
end