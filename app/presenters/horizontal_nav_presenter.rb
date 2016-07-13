class HorizontalNavPresenter < BasePresenter
  presents :horizontal_nav

  def present
    horizontal_nav_html
  end

  def horizontal_nav_html
    ul_tag do
      nav_lis
    end.html_safe
  end

  def nav_lis
    nav_link_objects.collect do |nav_link_object|
      li_tag(nav_link_object) do
        nav_link(nav_link_object)
      end
    end.join("\n").html_safe
  end

  def nav_link_objects
    horizontal_nav.link_objects.select do |obj|
      obj.kind_of?(Hash) || can?(:read, obj)
    end
  end

  private

  def ul_tag
    content_tag :ul, id: 'horizontal_nav', class: 'nav navbar-nav nav-pills', data: {
      breadcrumb_root_path: page_path(horizontal_nav.breadcrumb_root),
      sortable: (not horizontal_nav.currently_in_intranet? and can?(:manage, current_home_page))
    } do
      yield
    end
  end

  def li_tag(nav_link_object)
    unless nav_link_object.kind_of? Hash
      navable = nav_link_object
      css_class = "active" if navable_is_currently_shown?(navable)
      css_class ||= "under_this_category" if navable_is_most_special_category?(navable)
    end
    content_tag :li, :class => "horizontal-nav-link #{css_class}" do
      yield
    end
  end

  def nav_link(link_object)
    title = possibly_shortened_title_for(link_object)
    object = link_object
    object = link_object.except(:title) if link_object.kind_of? Hash

    options = {}
    if link_object.try(:id)
      options = options.merge({data: {
        vertical_nav_path: vertical_nav_path(navable_type: object.class.base_class.name, navable_id: object.id),
        page_id: (link_object.id if link_object.kind_of?(Page))
      }})
    end

    link_to title, object, options
  end

  def current_navable
    horizontal_nav.current_navable
  end

  def navable_is_currently_shown?( navable )
    navable == current_navable
  end

  def navable_is_most_special_category?( navable )
    navable == most_special_category
  end

  def most_special_category
    categories_the_current_navable_falls_in.try(:select) do |navable|
      (navable.descendants & categories_the_current_navable_falls_in).empty?
    end.try(:first)
  end

  def categories_the_current_navable_falls_in
    if horizontal_nav.current_navable
      horizontal_nav.navables.select do |navable|
        ( horizontal_nav.current_navable.ancestors + [ horizontal_nav.current_navable ] ).include? navable
      end
    end
  end

  def possibly_shortened_title_for(object)
    if total_length_of_titles > 60
      shortened_title_for(object)
    else
      title_for(object)
    end
  end

  def title_for(object)
    title = object[:title] if object.kind_of? Hash
    title ||= object.nav_node.menu_item if object.respond_to?(:nav_node) && object.nav_node
    title ||= object.title if object
    title ||= ""
  end

  def shortened_title_for(object)
    if object.kind_of? Hash
      title_for(object)
    else
      navable = object
      title = navable.internal_token if navable.respond_to? :internal_token
      title ||= navable.token if navable.respond_to? :token
      title ||= title_for(navable)
    end
  end

  def total_length_of_titles
    nav_link_objects.collect { |object| title_for(object).length }.sum
  end

end
