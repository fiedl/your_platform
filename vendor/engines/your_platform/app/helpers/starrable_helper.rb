module StarrableHelper

  def star_tool( user, starrable )
    if user and starrable
      star_toggler_link( user, starrable ) do
        if Star.user_starred_object? user, starrable
          content_tag :span, starred_character, :class => "starred star"
        else
          content_tag :span, unstarred_character, :class => "unstarred star"
        end
      end
    end
  end

  private

  def star_toggler_link( user, starrable )
    link_to( 
            star_path( id: nil, 
                       user_id: user.id, 
                       starrable_id: starrable.id, starrable_type: starrable.class.name )
            , method: :put ) 
    do
      yield
    end
  end

  def starred_character
    "&#9733;".html_safe
  end

  def unstarred_character
    "&#9734;".html_safe
  end

end
