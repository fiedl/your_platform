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
    horizontal_nav.link_objects
  end
  
  private
  
  def ul_tag
    content_tag :ul, :class => "nav nav-tabs" do
      yield
    end
  end
  
  def li_tag(nav_link_object)
    unless nav_link_object.kind_of? Hash
      navable = nav_link_object 
      css_class = "active" if navable_is_currently_shown?(navable)
      css_class ||= "under_this_category" if navable_is_most_special_category?(navable)
    end
    content_tag :li, :class => css_class do
      yield
    end
  end
  
  def nav_link(link_object)
    title = possibly_shortened_title_for(link_object)
    object = link_object
    object = link_object.except(:title) if link_object.kind_of? Hash
    link_to title, object
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
    title = object[:title] if object
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
