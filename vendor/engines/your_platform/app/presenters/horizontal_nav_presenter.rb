class HorizontalNavPresenter < BasePresenter
  presents :horizontal_nav
  
  def html_for_backend_nav
    content_tag :ul do
      lis_for_backend_nav
    end.html_safe
  end
  
  def lis_for_backend_nav
    link_objects_for_backend_nav.collect do |link_object|
      content_tag :li do
        title = link_object[:title] || link_object.title
        link_to title, link_object
      end
    end.join.html_safe
  end
  def link_objects_for_backend_nav
    horizontal_nav.navables || []
  end
  
  private
  
  
end
