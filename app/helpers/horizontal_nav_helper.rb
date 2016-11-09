module HorizontalNavHelper

  def horizontal_nav
    horizontal_nav_for current_navable
  end

  def horizontal_nav_for(navable)
    Rails.cache.fetch([current_user, "horizontal_nav", navable]) do
      present HorizontalNav.for_user(current_user, current_navable: navable)
      #end
  end

  def horizontal_nav_lis
    present HorizontalNav.for_user(current_user, current_navable: current_navable) do |presenter|
      presenter.nav_lis
    end
  end
end
