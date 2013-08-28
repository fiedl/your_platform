# -*- coding: utf-8 -*-
module BreadcrumbsHelper
  
  # This returns the html code for an unordered list containing the
  # bread crumb elements.
  def breadcrumb_ul
    return breadcrumb_ul_for_navable @navable if @navable
    return breadcrumb_ul_for_navables @navables if @navables
  end
  
  def breadcrumb_ul_for_navable( navable )
    content_tag :ul do
      breadcrumbs = navable.nav_node.breadcrumbs   # => [ { title: 'foo', navable: ... }, ... ]
      breadcrumb_lis_for_breadcrumb_hashes( breadcrumbs )
    end
  end

  def breadcrumb_ul_for_navables( navables = [] )
    breadcrumbs = navables.collect do |navable|
      breadcrumb = { title: navable.title, navable: navable }
    end
    content_tag :ul do
      breadcrumb_lis_for_breadcrumb_hashes( breadcrumbs )
    end
  end

  def breadcrumb_lis_for_breadcrumb_hashes( breadcrumbs )
    breadcrumbs.collect do |breadcrumb|
      css_class = "crumb"
      css_class = "root crumb" if breadcrumb == breadcrumbs.first
      css_class = "last crumb" if breadcrumb == breadcrumbs.last
      css_class += " slim" if breadcrumb[ :slim ]
      c = content_tag :li, :class => css_class do
        link_to breadcrumb[ :title ], breadcrumb[ :navable ]
      end
      unless breadcrumb == breadcrumbs.last
        c+= content_tag :li, "&nbsp;".html_safe, :class => "crumb sep"
      end
      c
    end.join.html_safe
  end

end
