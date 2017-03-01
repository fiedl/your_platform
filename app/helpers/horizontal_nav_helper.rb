module HorizontalNavHelper

  def horizontal_nav
    @horizontal_nav ||= HorizontalNav.for_user current_user, current_navable: current_navable, current_home_page: current_home_page
  end

  def horizontal_nav_li_css_class(navable)
    return nil if not current_navable
    return "active" if navable == current_navable
    return "under_this_category" if navable.in?(@current_navable_ancestors ||= current_navable.ancestor_navables)
  end

end
