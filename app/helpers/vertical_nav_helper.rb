# This extends the your_platform VerticalNavHelper
require_dependency YourPlatform::Engine.root.join( 'app/helpers/vertical_nav_helper' ).to_s

module VerticalNavHelper
  
  # Override the vertical_nav method in order to show the button "aktivmeldung"
  # in the vertical menu.
  #
  alias_method :orig_vertical_nav, :vertical_nav
  def vertical_nav
    (orig_vertical_nav + content_tag(:p, aktivmeldungsbutton)).html_safe
  end
  
end
