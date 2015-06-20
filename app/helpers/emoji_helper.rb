module EmojiHelper
  
  # https://github.com/github/gemoji
  #
  def emojify(content)
    content.to_str.gsub(/:([\w+-]+):/) do |match|
      if emoji = Emoji.find_by_alias($1)
        %(<img alt="#{$1}" src="#{image_path("emoji/#{emoji.image_filename}")}" style="vertical-align:middle" width="20" height="20" />)
      else
        match
      end
    end.html_safe if content.present?
  end
end

# In order to use the helper method with best_in_place's :display_with argument, 
# the ActionView::Base has to include the method.
#
module ActionView
  class Base
    include EmojiHelper
  end
end
