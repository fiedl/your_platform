module VerticalNavHelper
  
  # Returns the html code for the vertical navigation, i.e. the vertical menu.
  #
  def vertical_nav
    render partial: 'layouts/vertical_nav'
  end

  # Generates the HTML code for a vertical menu, where the given navable object, 
  # e.g. a Page or a User, is the currently active element.
  #
  def vertical_menu_for( navable )
    if navable
      html_code = ""
      active_navable = navable
      ancestor_navables = navable.nav_node.ancestor_navables
      child_navables = navable.navable_children
      html_code += menu_elements( ancestor_navables, :ancestor )
      html_code += menu_element( active_navable, :active )
      html_code += menu_elements( child_navables, :child )
      return html_code.html_safe
    end
  end
  
  def show_vertical_nav?
    @navable.present?
  end

  private

  def menu_elements( objects, element_class )
    objects.collect do |object|
      should_not_be_displayed = false
      should_not_be_displayed = true if object.nav_node.hidden_menu and element_class == :child
      should_not_be_displayed = true if object.nav_node.slim_menu and element_class == :ancestor
      should_not_be_displayed = true if cannot? :read, object
      menu_element( object, element_class ) unless should_not_be_displayed 
    end.join.html_safe
  end

  def menu_element( object, element_class )
    title = object.title
    content_tag( :li, :class => element_class ) do 
      link_to title, object
    end
  end
  
end
