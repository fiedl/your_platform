module MenuHelper

  # Generates html code for a vertical menu. 
  # Parameters:
  #   root:           Object that is displayed as root element of the menu, typically Page.find_root.
  #   active_element: Object that is displayed as active element of the menu.
  def vertical_menu( params )
    root = params[ :root ]
    active_element = params[ :active_element ]
    
    html_code = ""
    html_code += menu_elements( active_element.ancestors, :parent )
    html_code += menu_element( active_element, :active )
    html_code += menu_elements( active_element.children, :child )
    return html_code.html_safe

  end
  
  # Generates html code for a vertical menu, representing the given object as root menu element.
  def submenu_for( object )
    
    html_code = ""

    html_code += menu_element object, :root

    html_code += menu_elements object.child_pages, :child if object.child_pages.count > 0 if object.respond_to? :child_pages
    html_code += menu_elements object.child_users, :child if object.child_users.count > 0 if object.respond_to? :child_users
    

    return html_code.html_safe

  end

  private

  def menu_elements( objects, element_class )
    html_code = ""
    objects.each do |object|
      html_code += menu_element( object, element_class )
    end
    return html_code
  end

  def menu_element( object, element_class )
    title = object.name if object.kind_of? User
    title = object.title if object.kind_of? Page
    url_options = {}
    url_options = { controller: 'users', action: 'show', alias: object.alias } if object.kind_of? User
    content_tag( :li, :class => element_class ) do 
      link_to title, url_options
    end
  end
  
end
