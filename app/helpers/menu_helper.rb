# -*- coding: utf-8 -*-
module MenuHelper

  # Generates html code for a vertical menu. 
  # Parameters:
  #   root:           Object that is displayed as root element of the menu, typically Page.find_root.
  #   active_element: Object that is displayed as active element of the menu.
#  def vertical_menu( params )
#    root = params[ :root ]
#    active_element = params[ :active_element ]
#    
#    html_code = ""
#    html_code += menu_elements( active_element.ancestors, :parent )
#    html_code += menu_element( active_element, :active )
#    html_code += menu_elements( active_element.children, :child )
#    return html_code.html_safe
#
#  end
  
#  # Generates html code for a vertical menu, representing the given object as root menu element.
#  def submenu_for( object )
#    
#    html_code = ""
#
#    html_code += menu_element object, :root
#
#    html_code += menu_elements object.child_pages, :child if object.child_pages.count > 0 if object.respond_to? :child_pages
#    html_code += menu_elements object.child_users, :child if object.child_users.count > 0 if object.respond_to? :child_users
#    
#
#    return html_code.html_safe
#
#  end

  # Generates the HTML code for a navable object, e.g. a Page or a User.
  def vertical_menu_for( navable )
    html_code = ""
    active_navable = navable
    ancestor_navables = navable.nav_node.ancestor_navables
    child_navables = navable.children
    html_code += menu_elements( ancestor_navables, :ancestor )
    html_code += menu_element( active_navable, :active )
    html_code += menu_elements( child_navables, :child )
    return html_code.html_safe
  end

  # Generates the HTML Code for the current @navable object.
  def vertical_menu
    vertical_menu_for @navable if @navable
  end


  private

  def menu_elements( objects, element_class )
    objects.collect do |object|      
      menu_element( object, element_class ) #unless object.nav_node.slim_menu # TODO: Das ist für übergeordnete Elemente falsch!
    end.join.html_safe
  end

  def menu_element( object, element_class )
    title = object.title
#    title = object.name if object.kind_of? User
#    title = object.title if object.kind_of? Page
#    url_options = {}
#    url_options = { controller: 'users', action: 'show', alias: object.alias } if object.kind_of? User
    content_tag( :li, :class => element_class ) do 
      link_to title, object
    end
  end
  
end
