class PagesController < ApplicationController
  include MarkdownHelper

  before_action :find_resource_by_permalink, only: [:show, :update]
  before_action :find_resource_by_id, only: [:show, :update]
  load_resource only: [:destroy]
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

      if @page.settings.show_events
        if @page.settings.show_events_for_group_id
          @events = Group.find(@page.settings.show_events_for_group_id.to_i).events
        else
          @events = Event.all
        end
        @events = @events.where(publish_on_global_website: true) if @page.settings.show_only_events_published_on_global_website
        @events = @events.where(publish_on_local_website: true) if @page.settings.show_only_events_published_on_local_website
        @events = @events.upcoming.order('events.start_at, events.created_at').limit(5)
        @events = @events.select { |event| current_ability.can? :read, event }
      end

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
      elsif @page.group
        set_current_access :group
        set_current_access_text I18n.t(:members_of_group_name_can_read_this_content, group_name: @page.group.name)
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

    if page_params[:content]
      params[:page][:content] = html2markdown params[:page][:content]
    end

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
    params[:page][:title] ||= I18n.t(:new_page)
    params[:page][:author_user_id] ||= current_user.id
    @new_page = @association.create!(page_params)

    redirect_to @new_page
  end

  def destroy
    @parent = @page.parents.first || Page.intranet_root
    @page.destroy

    respond_to do |format|
      format.html { redirect_to @parent }
      format.json { render json: {redirect_to: url_for(@parent)} }
    end
  end


private

  def page_params
    # For some tools, like best_in_place, we need to sync up the params of single-table-inherited
    # models, like blog posts. For example, if `BestInPlace::Utils.object_to_key(blog_post)` returns
    # "blog_post", `params[:blog_post]` needs to be filled. On the other hand, the operations below
    # operate on the `params[:page]` hash. I.e. we need both sync directions.
    #
    params[:page] ||= params[:blog_post]
    params[:blog_post] ||= params[:page]

    params[:page] ||= {}
    params[:page][:archived] ||= params[:archived]

    params[:page][:type] = "BlogPost" if params[:type] == 'blog_post'
    if params[:type] == "hidden"
      params[:show_in_menu] = false
      params[:show_as_teaser_box] = false
    end

    handle_checkbox_param :show_in_menu
    handle_checkbox_param :show_as_teaser_box
    handle_checkbox_param :show_group_map

    permitted_keys = []
    permitted_keys += [:title, :content, :box_configuration => [:id, :class]] if can? :update, (@page || raise('@page not given'))
    permitted_keys += [:teaser_text, :teaser_image_url] if can? :update, @page
    permitted_keys += [:redirect_to] if can? :update, @page
    permitted_keys += [:tag_list, :permalinks_list] if can? :update, @page
    permitted_keys += [:type, :author, :author_title, :author_user_id, :archived] if can? :manage, @page
    permitted_keys += [:layout, :home_page_title, :home_page_sub_title] if @page.kind_of? Pages::HomePage and can? :manage, @page
    permitted_keys += [:nav_node_attributes => [:hidden_menu, :hidden_teaser_box]] if can? :update, @page
    permitted_keys += [:show_group_map, :group_map_parent_group_id] if can? :manage, @page
    permitted_keys += [:settings => [:horizontal_nav_page_id_order => []]] if can? :manage, @page

    if (@page.new_record? and can?(:create_page_for, secure_parent)) or can?(:manage, @page)
      permitted_keys += [:title, :content, :type, :author_user_id]
      permitted_keys += [:hidden_menu, :slim_menu, :slim_breadcrumb, :show_as_teaser_box, :show_in_menu]
    end

    params.require(:page).permit(*permitted_keys)
  end

  def handle_checkbox_param(param)
    # For example: params[:page][:show_in_menu] ||= params[:show_in_menu]
    params[:page][param] ||= params[param] if params[param]
    params[:page][param] = false if params[:page][param].in? ["0", "false"]
    params[:page][param] = true if params[:page][param] == "true"
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
