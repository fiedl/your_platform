module HorizontalNavHelper
  def backend_horizontal_nav
    present(HorizontalNav.for_user(current_user, current_navable: @navable)) do |horizontal_nav|
      horizontal_nav.html_for_backend_nav
    end
  end
end
