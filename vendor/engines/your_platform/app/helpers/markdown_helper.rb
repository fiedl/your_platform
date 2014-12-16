module MarkdownHelper
  # This method returns the given markdown code rendered as html.
  # Have a look at these sources:
  #   * http://railscasts.com/episodes/272-markdown-with-redcarpet
  #   * https://github.com/vmg/redcarpet
  #   * http://daringfireball.net/projects/markdown/syntax
  #
  def markdown(text, options = nil)
    options ||= { hard_wrap: true, filter_html: false, autolink: true, no_intraemphasis: true, fenced_code: true, gh_blockcode: true }
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, options).render(text || "").html_safe
  end
end

# In order to use the markdown helper method with best_in_place's :display_with argument, 
# the ActionView::Base has to include the markdown method.
#
module ActionView
  class Base
    include MarkdownHelper
  end
end
