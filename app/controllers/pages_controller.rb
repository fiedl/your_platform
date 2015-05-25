class PagesController < ApplicationController

  load_and_authorize_resource
  skip_authorize_resource only: [:create]
  
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
      
      if @page.has_flag?(:intranet_root)
        redirect_to root_path
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
    params[:blog_post] ||= params[:page]  # required for blog posts in respond_with_bip
    @page.update_attributes params[ :page ]
    respond_with_bip(@page)
  end
  
  def create
    if secure_parent
      @association = secure_parent.child_pages
      authorize! :create_page_for, secure_parent
    else
      @association = Page
      authorize! :create, Page
    end
    @new_page = @association.create( title: I18n.t(:new_page) )
    @new_page.author = current_user
    @new_page.save
    redirect_to @new_page
  end
  
  def destroy
    @parent = @page.parents.first
    @page.destroy

    respond_to do |format|
      format.html { redirect_to @parent }
      format.json { render json: {redirect_to: url_for(@parent)} }
    end
  end
  
  
private

  def secure_parent
    # params[:parent_type] ||= params[:page][:parent_type] if params[:page]
    # params[:parent_id] ||= params[:page][:parent_id] if params[:page]
    params[:parent_type] ||= 'Page' if params[:parent_id]
    secure_parent_type.constantize.find(params[:parent_id]) if secure_parent_type && params[:parent_id].present?
  end
  
  def secure_parent_type
    params[:parent_type] if params[:parent_type].in? ['Page', 'Group', 'Event']
  end

end
