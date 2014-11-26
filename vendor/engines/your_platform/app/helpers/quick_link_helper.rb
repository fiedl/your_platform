#
# On Pages, the main text is parsed for expressions like "[[Foo Bar]]".
# These expressions generate links to "/search/guess?query=Foo+Bar".
# The SearchController handles the redirection to the requested content.
# 
# This can be used to insert quick links to user, pages and other types
# of content.
#
module QuickLinkHelper
  
  def replace_quick_link_tags(text)
    text.gsub(/\[\[.*\]\]/) { |query| link_tag_from_search_query(query.gsub('[', '').gsub(']', '')) } if text.present?
  end
  
  private
  
  def link_tag_from_search_query(query)
    link_to(
      query, 
      link_url_from_search_query(query)
    ).html_safe
  end
  
  def link_url_from_search_query(query)
    Rails.application.routes.url_for({controller: :search, action: :lucky_guess, query: query, only_path: true})
  end
  
  # "foo, bar" 
  # ->  "<a href=/search/foo>foo</a>, <a href=/search/bar>bar</a>"
  #
  def add_quick_links_to_comma_separated_list(str)
    str.split(",").collect do |name|
      link_tag_from_search_query(name.strip)
    end.join(", ").html_safe
  end
  
end

# In order to use the helper method with best_in_place's :display_with argument, 
# the ActionView::Base has to include the module.
#
module ActionView
  class Base
    include QuickLinkHelper
  end
end
