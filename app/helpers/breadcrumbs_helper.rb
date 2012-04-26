# -*- coding: utf-8 -*-
module BreadcrumbsHelper

  # Erzeugt eine ungeordnete Liste der Breadcrumb-Elemente für das navigationsfähige Objekt +navable+, 
  # z.B. einen Benutzer (User) oder eine Seite (Page).
  def breadcrumb_ul_for_navable( navable )
    content_tag :ul do
      breadcrumbs = navable.nav_node.breadcrumbs
      breadcrumbs.collect do |breadcrumb|
        content_tag :li do
          if breadcrumb == breadcrumbs.last
            breadcrumb[ :title ]
          else
            link_to breadcrumb[ :title ], breadcrumb[ :navable ]
          end
        end
      end.join.html_safe
    end
  end

  def breadcrumb_ul
    breadcrumb_ul_for_navable @navable if @navable
  end

end
