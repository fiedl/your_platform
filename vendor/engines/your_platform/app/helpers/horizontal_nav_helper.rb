module HorizontalNavHelper
  def horizontal_nav
    present HorizontalNav.for_user(current_user, current_navable: current_navable)
  end
end
