module MarkdownHelper
  # This method returns the given markdown code rendered as html.
  # Have a look at these sources:
  #   * http://railscasts.com/episodes/272-markdown-with-redcarpet
  #   * https://github.com/vmg/redcarpet
  #   * http://daringfireball.net/projects/markdown/syntax
  #
  def markdown(text, options = nil)
    markdown_options = options || {autolink: true, no_intraemphasis: true, fenced_code: true, gh_blockcode: true}
    renderer_options = options || {hard_wrap: true, filter_html: false}

    # To prevent the numbering issue with ordered lists, simply
    # convert all numbered lists to unordered ones.
    #
    text = text.gsub(/^([0-9]*\. .*$)/, '* \1')

    rendered_html = Redcarpet::Markdown.new(Redcarpet::Render::ModifiedHtml.new(renderer_options.merge({unrendered_content: text})), markdown_options).render(text || "").html_safe

    # There are cases when the rendered html results in
    # "invalid byte sequence in UTF-8" when the input came from
    # an email. Therefore, check encoding issues first.
    #
    rendered_html.valid_encoding? ? rendered_html : text
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
