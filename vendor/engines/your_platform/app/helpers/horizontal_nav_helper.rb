module HorizontalNavHelper
  def horizontal_nav
    present HorizontalNav.for_user(current_user, current_navable: @navable)
  end
end
