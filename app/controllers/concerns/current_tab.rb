concern :CurrentTab do
  
  included do
    helper_method(:current_tab_path)
  end
  
  # This method returns the correct path for the given object
  # considering the current tab the user has used last.
  #
  def current_tab_path(object)
    if object.kind_of?(Group) and can?(:use, :tab_view)
      case cookies[:group_tab]
      when "posts"; group_posts_path(object)
      when "profile"; group_profile_path(object)
      when "events"; group_events_path(object)
      when "members"; group_members_path(object)
      when "officers"; group_officers_path(object)
      when "settings"; group_settings_path(object)
      else group_profile_path(object)
      end
    else
      object
    end
  end
  
end