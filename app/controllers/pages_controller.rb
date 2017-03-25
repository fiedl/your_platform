class PagesController < ApplicationController

  before_action :find_resource_by_permalink, only: [:show, :update]
  before_action :find_resource_by_id, only: [:show, :update]
  load_resource except: [:show, :update]
  authorize_resource
  skip_authorize_resource only: [:create]

  respond_to :html, :json

  def show
    authorize! :read, @page
    if @page
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

      @blog_entries = @page.blog_entries.for_display

      set_current_title @page.title
      set_current_navable @page
      set_current_activity :looks_up_information, @page
      set_current_tab :pages

      if @page.group
        set_current_access :group
        set_current_access_text I18n.t(:members_of_group_name_can_read_this_content, group_name: @page.group.name)
      elsif @page.public? or @page.has_flag?(:imprint)
        set_current_access :public
        set_current_access_text :this_is_the_public_website_and_can_be_read_by_all_internet_users
      else
        set_current_access :signed_in
        set_current_access_text :all_signed_in_users_can_read_this_content
      end

    end
    metric_logger.log_event @page.attributes, type: :show_page
    respond_with @page
  end

  def update
    authorize! :update, @page
    params[:page] ||= {}
    params[:page][:archived] ||= params[:archived]  # required for archivable.js.coffee to work properly.
    params[:blog_post] ||= params[:page]  # required for blog posts in respond_with_bip
    @page.update_attributes!(page_params)
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

  def page_params
    params.require(:page).permit(:content, :title, :teaser_text, :redirect_to, :author, :tag_list, :teaser_image_url, :archived)
  end

  def find_resource_by_permalink
    page_id = Permalink.find_by(path: params[:permalink], reference_type: 'Page').try(:reference_id)
    @page ||= Page.find(page_id) if page_id
  end

  def find_resource_by_id
    @page ||= Page.find(params[:id])
  end

  def secure_parent
    # params[:parent_type] ||= params[:page][:parent_type] if params[:page]
    # params[:parent_id] ||= params[:page][:parent_id] if params[:page]
    params[:parent_type] ||= 'Page' if params[:parent_id]
    secure_parent_type.constantize.find(params[:parent_id]) if secure_parent_type && params[:parent_id].present?
  end

  def secure_parent_type
    params[:parent_type] if params[:parent_type].in? ['Page', 'Group', 'Event', 'User']
  end

end
