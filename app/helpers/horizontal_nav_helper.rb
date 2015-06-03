module HorizontalNavHelper
  def horizontal_nav
    Rails.cache.fetch([current_user, "horizontal_nav", current_navable]) do
      present HorizontalNav.for_user(current_user, current_navable: current_navable)
    end
  end
  
  def horizontal_nav_lis
    present HorizontalNav.for_user(current_user, current_navable: current_navable) do |presenter|
      presenter.nav_lis
    end
  end
end
