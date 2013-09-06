module HorizontalNavHelper
  def horizontal_nav
    present HorizontalNav.for_user(current_user, current_navable: current_navable)
  end
  
  def horizontal_nav_lis
    present HorizontalNav.for_user(current_user, current_navable: current_navable) do |presenter|
      presenter.nav_lis
    end
  end
end
