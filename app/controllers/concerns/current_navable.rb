concern :CurrentNavable do
  
  included do
    helper_method :current_navable, :point_navigation_to, :set_current_navable
  end
  
  # This method returns the navable object the navigational elements on the 
  # currently shown page point to.
  #
  # For example, if the bread crumb navigation reads 'Start > Intranet > News', 
  # the current_navable would return the with 'News' associated navable object.
  # 
  # This also means, that the current_navable has to be set in the controller
  # through point_navigation_to.
  # 
  def current_navable
    @navable
  end
  
  # This method sets the currently shown navable object. 
  # Have a look at #current_navable.
  #
  def point_navigation_to(navable)
    set_current_navable(navable)
  end
  def set_current_navable(navable)

    @navable = navable
    
    # We have to reload the current_ability at this point, i.e. after executing
    # authorize_miniprofiler et cetera, because before, the current_navable is not
    # available and the abilities might change now depending on the user's role
    # for the current_navable.
    reload_ability
  end
  
end