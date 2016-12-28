module YouTubeHelper

  # Convert YouTube links to embedding iframes.
  # Using auto html: https://github.com/dejan/auto_html
  #
  def youtubify(content)
    AutoHtml.auto_html(content) do
      youtube(autoplay: false)
    end.html_safe
  end

  def you_tube(content)
    youtubify content
  end

end

# In order to use the helper method with best_in_place's :display_with argument,
# the ActionView::Base has to include the method.
#
module ActionView
  class Base
    include YouTubeHelper
  end
end
