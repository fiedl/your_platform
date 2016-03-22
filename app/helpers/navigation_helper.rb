module NavigationHelper
  
  # In some cases, we need to reload the navigation elements after rendering the view.
  # For example, for newly created events, the parent group is set after showing the
  # event, in order to save time on event creation.
  #
  # Call `reload_navigation` from the view in order to have the navigation elements
  # reload after a couple of seconds.
  #
  def reload_navigation
    content_tag :div, "", class: "reload-navigation", data: {navable: current_navable.to_global_id.to_s}
  end

end