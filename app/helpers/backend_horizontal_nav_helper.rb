module BackendHorizontalNavHelper

  def backend_horizontal_nav
    backend_horizontal_nav_for_user @current_user
  end


  def backend_horizontal_nav_for_user( user )
    important_navables = []
    important_navables += [ Page.mitglieder_start ] if Page.mitglieder_start
    important_navables += user.corporations if user.corporations if user
    important_navables += [ user.bv.becomes( Group ) ] if user.bv if user
    content_tag :ul do
      important_navables.collect do |navable|
        backend_horizontal_nav_item navable
      end.join.html_safe
    end
  end

  def backend_horizontal_nav_item( navable )
    style_class = "active" if navable == @navable
    style_class = "under_this_category" if @navable.ancestors.include? navable if @navable
    content_tag :li, :class => style_class do
      title = navable.title
      title = navable.token if navable.respond_to? :token if title.length > 16
      link_to title, navable
    end
  end

end
