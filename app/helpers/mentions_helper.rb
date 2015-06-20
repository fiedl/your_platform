module MentionsHelper
  
  # https://github.com/github/gemoji
  #
  def mentionify(content)
    content.to_str.gsub(/@\[\[(.*)\]\]/) do |match|
      "<span class='mention'>#{match}</span>"
    end.html_safe if content.present?
  end
  
end

# In order to use the helper method with best_in_place's :display_with argument, 
# the ActionView::Base has to include the method.
#
module ActionView
  class Base
    include MentionsHelper
  end
end
