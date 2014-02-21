# This helper abstracts the several markup methods
# into one method `markup()`.
#
# For example, on a Page, use:
# 
#   <div id="content">
#     <%= markup(@page.content) %>
#   </div>
#
module MarkupHelper
  
  def markup(text)
    markdown replace_quick_link_tags text
  end
  
end

# In order to use the markup helper method with best_in_place's :display_with argument, 
# the ActionView::Base has to include the markup method.
#
module ActionView
  class Base
    include MarkupHelper
  end
end
