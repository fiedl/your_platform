concern :CurrentTab do

  included do
    helper_method :current_tab, :current_tab_path, :tab_path
  end

  # This method returns the correct path for the given object
  # considering the current tab the user has used last.
  #
  def current_tab_path(object)
    tab_path object, current_tab(object)
  end

  def tab_path(object, tab)
    if object.kind_of?(Groups::GroupOfGroups)
      group_path(object)
    elsif object.kind_of?(Group)
      case tab.to_s
      when "subgroups"; group_path(object)
      when "news"
        if resource_centred_layout?
          group_news_path(object)
        else
          group_members_path(object)
        end
      when "posts"
        if can? :index_posts, object
          group_posts_path(object)
        else
          group_profile_path(object)
        end
      when "profile"; group_profile_path(object)
      when "events"; group_events_path(object)
      when "members"; group_members_path(object)
      when "officers"; group_officers_path(object)
      when "pages"; group_pages_path(object)
      when "settings"
        if can? :change_group_settings, object
          group_settings_path(object)
        else
          group_profile_path(object)
        end
      else group_profile_path(object)
      end
    else
      polymorphic_path object
    end
  end

  def current_tab(object = nil)
    object ||= current_navable
    cookies[:current_tab]
  end

  def set_current_tab(tab)
    cookies[:current_tab] = tab
  end

end