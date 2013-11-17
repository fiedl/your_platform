class PagesController < ApplicationController

  load_and_authorize_resource
  respond_to :html, :json

  def show
    if @page
      if @page.redirect_to
        redirect_to @page.redirect_to
        return
      end

      @blog_entries = @page.blog_entries.limit(10)

      @title = @page.title
      @navable = @page
      @page = @page.becomes(Page)  # rather than BlogPost etc.
    end
    respond_with @page
  end

  def update
    @page.update_attributes params[ :page ]
    respond_with_bip(@page)
  end

  def create
    if params[:parent_type].present? && params[:parent_id].present?
      @parent = params[:parent_type].constantize.find(params[:parent_id]).child_pages
    else
      @parent = Page
    end
    @new_page = @parent.create( title: I18n.t(:new_page) )
    @new_page.author = current_user
    @new_page.save
    redirect_to @new_page
  end

end
