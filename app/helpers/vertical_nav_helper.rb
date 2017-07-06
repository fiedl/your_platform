module VerticalNavHelper

  def show_vertical_nav?
    (not @hide_vertical_nav) && @navable.present? && @navable.show_vertical_nav?
  end

  def link_to_navable(title, navable)
    link_to(title, current_tab_path(navable), data: {
      vertical_nav_path: vertical_nav_path(navable_type: navable.class.base_class.name, navable_id: navable.id),
      # corporation_name: (navable.corporation.try(:name) if navable.respond_to?(:corporation))
      page_id: (navable.id if navable.kind_of?(Page))
    })
  end

  # For certain collection groups it's useful to have the corporation
  # name in parentheses added to the child group name.
  #
  # All Presidents       >    All President
  #      |- President    >         |- President (Berlin)
  #      |- President    >         |- President (London)
  #      |- President    >         |- President (Paris)
  #      |- President    >         |- President (New York)
  #
  def show_corporation_names_in_vertical_nav?(navable)
    if @show_corporation_names_in_vertical_nav.nil?
      @show_corporation_names_in_vertical_nav = navable.kind_of?(Group) && (not ((navable.ancestor_navables + [navable]).include?(navable.corporation)))
    else
      @show_corporation_names_in_vertical_nav
    end
  end

end
