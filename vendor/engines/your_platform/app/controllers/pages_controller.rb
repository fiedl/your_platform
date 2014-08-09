class PagesController < ApplicationController

  load_and_authorize_resource
  respond_to :html, :json

  def show
    if @page
      current_user.try(:update_last_seen_activity, "sieht sich Informationen an: #{@page.title}", @page)

      if @page.redirect_to
        target = @page.redirect_to
        
        # In order to avoid multiple redirects, we force https manually here
        # in production.
        #
        target.merge!({protocol: "https://"}) if target.kind_of?(Hash) && Rails.env.production?
        
        redirect_to target
        return
      end

      @blog_entries = @page.blog_entries.limit(10)

      @title = @page.title
      @navable = @page
      @page = @page.becomes(Page)  # rather than BlogPost etc.
    end
    metric_logger.log_event @page.attributes, type: :show_page
    respond_with @page
  end

  def update
    @page.update_attributes params[ :page ]
    respond_with_bip(@page)
  end

  def create
    if secure_parent_type.present? && params[:parent_id].present?
      @parent = secure_parent_type.constantize.find(params[:parent_id]).child_pages
    else
      @parent = Page
    end
    @new_page = @parent.create( title: I18n.t(:new_page) )
    @new_page.author = current_user
    @new_page.save
    redirect_to @new_page
  end
  
private
  
  def secure_parent_type
    params[:parent_type] if params[:parent_type].in? ['Page', 'Group']
  end

end
