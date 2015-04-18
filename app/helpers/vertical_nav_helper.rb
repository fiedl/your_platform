module VerticalNavHelper
  
  # Returns the html code for the vertical navigation, i.e. the vertical menu.
  #
  def vertical_nav
    render partial: 'layouts/vertical_nav'
  end

  # Generates the HTML code for a vertical menu, where the given navable object, 
  # e.g. a Page or a User, is the currently active element.
  #
  def vertical_menu_for(navable)
    if navable
      @ancestor_navables = cached_ancestor_navables(navable)
      @active_navable = navable
      @active_navables = [@active_navable]
      @child_navables = cached_child_navables(navable)
      
      menu_elements_html(@ancestor_navables, :ancestor) +
      menu_element(@active_navable, :active) +
      menu_elements_html(@child_navables, :child)
    end
  end
  
  def show_vertical_nav?
    @navable.present?
  end

  private
  
  def cached_ancestor_navables(navable)
    NavNode
    Rails.cache.fetch([navable, 'ancestor_navables', navable.ancestors_cache_key], expires_in: 1.week) { ancestor_navables(navable) }
  end
  def ancestor_navables(navable)
    non_hidden_navables(navable.nav_node.ancestor_navables, :ancestor)
  end
  
  def cached_child_navables(navable)
    #NavNode
    #Rails.cache.fetch([navable, 'child_navables', navable.children_cache_key], expires_in: 1.week) { child_navables(navable) }
    child_navables(navable)
  end
  def child_navables(navable)
    non_hidden_navables(navable.navable_children, :child).sort_by do |object| 
      [ ['Page', 'Group'].index(object.class.base_class.name),  # pages above groups
      object.created_at]
    end
  end
  
  def non_hidden_navables(navables, element_class)
    navables.select do |navable|
      not(navable.nav_node.hidden_menu and element_class == :child) and
      not(navable.nav_node.slim_menu and element_class == :ancestor)
    end
  end

  def menu_elements_html(objects, element_class)
    objects.select { |object| can?(:read, object) }.collect do |object|
      menu_element(object, element_class)
    end.join.html_safe
  end

  def menu_element( object, element_class )
    content_tag( :li, :class => "#{element_class} #{object.class.name.downcase}" ) do 
      link_to(menu_element_title(object), object, data: {
        vertical_nav_path: vertical_nav_path(navable_type: object.class.base_class.name, navable_id: object.id)
      })
    end
  end
  
  def menu_element_title(object)
    if append_corporation_to_menu_element_title?(object)
      "#{object.title} (#{object.corporation.title})"
    else
      object.title
    end
  end
  
  def append_corporation_to_menu_element_title?(object)
    object.kind_of?(Group) &&
      object.corporation &&
      (not object.corporation.in?(@ancestor_navables + @active_navables)) &&
      (not object.corporation == object)
  end
end
