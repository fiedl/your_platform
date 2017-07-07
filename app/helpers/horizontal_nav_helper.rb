module HorizontalNavHelper

  def horizontal_nav
    @horizontal_nav ||= horizontal_nav_for current_navable
  end

  def horizontal_nav_for(navable, options = {})
    options[:home_page] ||= current_home_page
    HorizontalNav.for_user current_user, current_navable: navable, current_home_page: options[:home_page]
  end

  def horizontal_nav_li_css_class(navable)
    return nil if not current_navable
    return "active" if navable == current_navable
    return "under_this_category" if navable.in?(@current_navable_ancestors ||= current_navable.ancestor_navables)
  end

  def horizontal_nav_ul
    content_tag(:ul, class: 'horizontal_nav nav navbar-nav nav-pills', data: {
      breadcrumb_root_path: (page_path(horizontal_nav.breadcrumb_root) if horizontal_nav.breadcrumb_root),
      sortable: (not horizontal_nav.currently_in_intranet? and can?(:manage, current_home_page))
    }) { yield }
  end

end
