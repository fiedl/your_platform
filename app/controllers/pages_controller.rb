class PagesController < ApplicationController

  load_and_authorize_resource
  skip_authorize_resource only: [:create]

  respond_to :html, :json

  def show
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
      if @page.has_flag?(:root)
        redirect_to public_root_path
        return
      end

      @blog_entries = @page.blog_entries.for_display

      if @page.settings.show_events_box_for_group
        @events = Group.find(@page.settings.show_events_box_for_group).events
        @events = @events.where(publish_on_global_website: true) if @page.settings.show_only_events_published_on_global_website
        @events = @events.where(published_on_local_website: true) if @page.settings.show_only_events_published_on_local_website
        @events = @events.upcoming.order('events.start_at, events.created_at').limit(5)
        @events = @events.select { |event| current_ability.can? :read, event }
      end

      set_current_title @page.title
      set_current_navable @page
      set_current_activity :looks_up_information, @page

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
    if page_params[:content] && (page_params[:content].include?("<br>") || page_params[:content].include?("<p>"))
      params[:page][:content] = ReverseMarkdown.convert params[:page][:content]
    end

    @page.update_attributes page_params
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
    @parent = @page.parents.first
    @page.destroy

    respond_to do |format|
      format.html { redirect_to @parent }
      format.json { render json: {redirect_to: url_for(@parent)} }
    end
  end


private

  def page_params
    # STI override:
    params[:page] ||= params[:blog_post]

    params[:page] ||= {}
    params[:page][:archived] ||= params[:archived]
    params[:page][:type] = "BlogPost" if params[:type] == 'blog_post'
    if params[:show_in_menu] == "false" or params[:type] == "hidden"
      params[:page][:nav_node_attributes] ||= {}
      params[:page][:nav_node_attributes][:hidden_menu] = true
    end
    if params[:show_as_teaser_box] == "false" or params[:type] == "hidden"
      params[:page][:nav_node_attributes] ||= {}
      params[:page][:nav_node_attributes][:hidden_teaser_box] = true
    end
    params[:page][:show_corporation_map] = false if params[:page][:show_corporation_map].in? ["0", "false"]
    params[:page][:show_corporation_map] = true if params[:page][:show_corporation_map] == "true"

    permitted_keys = []
    permitted_keys += [:title, :content, :box_configuration => [:id, :class]] if can? :update, (@page || raise('@page not given'))
    permitted_keys += [:type, :author_user_id, :archived] if can? :manage, @page
    permitted_keys += [:title, :content, :type, :author_user_id] if @page.new_record? and can? :create_page_for, secure_parent
    permitted_keys += [:nav_node_attributes => [:hidden_menu, :hidden_teaser_box]] if can? :update, @page
    permitted_keys += [:hidden_menu, :slim_menu, :slim_breadcrumb] if can? :manage, @page
    permitted_keys += [:show_corporation_map] if can? :manage, @page

    params.require(:page).permit(*permitted_keys)
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
