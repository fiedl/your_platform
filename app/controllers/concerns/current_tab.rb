concern :CurrentTab do

  included do
    helper_method :current_tab, :current_tab_path
  end

  # This method returns the correct path for the given object
  # considering the current tab the user has used last.
  #
  def current_tab_path(object)
    if object.kind_of?(Group)
      case current_tab(object)
      when "subgroups"; group_subgroups_path(object)
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
      when "settings"
        if can? :change_group_settings, object
          group_settings_path(object)
        else
          group_profile_path(object)
        end
      else group_profile_path(object)
      end
    else
      object
    end
  end

  def current_tab(object = nil)
    object ||= current_navable
    if object.kind_of?(Group)
      if object.group_of_groups?
        "subgroups"
      else
        cookies[:group_tab]
      end
    end
  end

end