class PagesController < ApplicationController

  before_action :find_resource_by_permalink, only: [:show, :update]
  before_action :find_resource_by_id, only: [:show, :update]
  load_resource only: [:destroy]
  authorize_resource except: [:show, :create]
  skip_authorize_resource only: [:create]
  skip_authorization_check only: [:show]

  respond_to :html, :json

  include PageAnalyticsMetricLogging
  include MarkdownHelper

  def show
    if @page.try(:redirect_to)
      target = @page.redirect_to

      # In order to avoid multiple redirects, we force https manually here
      # in production.
      #
      target.merge!({protocol: "https://"}) if target.kind_of?(Hash) && Rails.env.production?

      redirect_to target
      return
    end

    if @page.public? && can?(:use, :fast_lane) && (not params[:no_fast_lane])
      event_ids = @page.events.upcoming.order('events.start_at, events.created_at').limit(3).pluck(:id) if @page.show_events?
      render html: (Rails.cache.fetch([@page, :fast_lane, event_ids]) {
        set_current_title @page.title
        set_current_navable @page
        @events = Event.find(event_ids) if event_ids
        use_the_fast_lane
        render_to_string template: 'pages/show'#, layout: false
      })#, layout: true
      return
    end

    authorize! :read, @page
    if @page
      if @page.has_flag?(:intranet_root)
        redirect_to root_path
        return
      end

      @blog_entries = @page.blog_entries.visible_to(current_user)

      if @page.show_events?
        @events = @page.events
        @events = @events.upcoming.order('events.start_at, events.created_at').limit(3)
        @events = @events.select { |event| current_ability.can? :read, event }
      end

      set_current_title @page.title
      set_current_navable @page
      set_current_activity :looks_up_information, @page
      set_current_tab :pages

      if @page.public? or @page.has_flag?(:imprint)
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
    params[:page] ||= {}
    params[:page][:title] ||= I18n.t(:new_page)
    params[:page][:author_user_id] ||= current_user.id
    @page = Page.new
    @new_page = @association.create!(page_params)

    if @new_page.embedded?
      redirect_to page_path(@new_page.parent, no_fast_lane: true)
    else
      redirect_to page_path(@new_page, no_fast_lane: true)
    end
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
    params[:page] ||= params[:pages_content_box]

    params[:page] ||= {}
    params[:page][:archived] ||= params[:archived] if params[:archived] # required for archivable.js.coffee to work properly.

    params[:page][:type] = "BlogPost" if params[:type] == 'blog_post'
    params[:page][:embedded] = true if params[:type] == 'content_box'
    if params[:type] == "hidden"
      params[:page][:show_in_menu] = params[:show_in_menu] = false
      params[:page][:show_as_teaser_box] = params[:show_as_teaser_box] = false
    end
    params[:box_configuration] = params[:box_configuration].to_h if params[:box_configuration]

    handle_checkbox_param :show_in_menu
    handle_checkbox_param :show_as_teaser_box
    handle_checkbox_param :show_group_map
    handle_checkbox_param :embedded
    handle_checkbox_param :show_in_footer
    handle_checkbox_param :footer_embedded

    permitted_keys = []
    permitted_keys += [:title, :content, :box_configuration => [:id, :class]] if can? :update, (@page || raise(ActionController::ParameterMissing, '@page not given'))
    permitted_keys += [:locale] if can? :update, @page
    permitted_keys += [:teaser_text, :teaser_image_url] if can? :update, @page
    permitted_keys += [:redirect_to] if can? :update, @page
    permitted_keys += [:tag_list, :permalinks_list] if can? :update, @page
    permitted_keys += [:type, :author, :author_title, :author_user_id, :archived] if can? :manage, @page
    permitted_keys += [:layout, :home_page_title, :home_page_sub_title] if @page.kind_of? Pages::HomePage and can? :manage, @page
    permitted_keys += [:domain] if can? :change_domain, @page
    permitted_keys += [:nav_node_attributes => [:hidden_menu, :hidden_teaser_box]] if can? :update, @page
    permitted_keys += [:show_group_map, :group_map_parent_group_id] if can? :manage, @page
    permitted_keys += [:show_events_for_group_id] if can? :manage, @page
    permitted_keys += [:show_officers_for_group_id] if can? :manage, @page
    permitted_keys += [:settings => [:horizontal_nav_page_id_order => []]] if can? :manage, @page
    permitted_keys += [:published_at, :localized_published_at] if can? :publish, @page

    if (@page.new_record? and can?(:create_page_for, secure_parent)) or can?(:manage, @page)
      permitted_keys += [:title, :content, :type, :author_user_id]
      permitted_keys += [:hidden_menu, :slim_menu, :slim_breadcrumb, :show_as_teaser_box, :embedded, :show_in_menu, :show_in_footer, :footer_embedded]
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
    page_id = Permalink.find_by(url_path: params[:permalink], reference_type: 'Page').try(:reference_id)
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
