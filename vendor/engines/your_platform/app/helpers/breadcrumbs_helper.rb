# -*- coding: utf-8 -*-
module BreadcrumbsHelper
  
  # This returns the html code for an unordered list containing the
  # bread crumb elements.
  #
  def breadcrumb_ul
    cached_breadcrumb_ul
  end
  
  def cached_breadcrumb_ul
    return cached_breadcrumb_ul_for_navable @navable if @navable
    return breadcrumb_ul_for_navables @navables if @navables
  end
  
  def cached_breadcrumb_ul_for_navable(navable)
    Rails.cache.fetch([navable, 'breadcrumb_ul_for_navable', navable.ancestors_cache_key]) { breadcrumb_ul_for_navable(navable) }
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

        # Do not use turbolinks for external links, since they are directed by the PagesController.
        # The redirect to external sites causes a 'forbidden' error when using turbolinks.
        #
        if breadcrumb[:navable].kind_of?(Page) && breadcrumb[:navable].redirect_to.kind_of?(String)
          link_options = {'data-no-turbolink' => true}
        else
          link_options = {}
        end

        link_to breadcrumb[ :title ], breadcrumb[ :navable ], link_options
      end
      unless breadcrumb == breadcrumbs.last
        c+= content_tag :li, "&nbsp;".html_safe, :class => "crumb sep"
      end
      c
    end.join.html_safe
  end

end
