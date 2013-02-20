module StarrableHelper

  def star_tool( user, starrable )
    if user and starrable
      star_toggler_link( user, starrable ) do
        if Star.user_starred_object? user, starrable
          character_span( true )
        else
          character_span( false )
        end
      end
    end
  end

  def starred_objects_lis( user )
    if user
      user.starred_objects.collect do |starrable|
        content_tag :li do
          link_to starrable.title, starrable
        end
      end
    end.join.html_safe
  end

  private

  def star_toggler_link( user, starrable )
    link_to( 
            star_path( user_id: user.id, 
                       starrable_id: starrable.id, starrable_type: starrable.class.name 
                       ), 
            method: :put,
            remote: true
            ) do
      yield
    end
  end

  def character_span( starred = true )
    character = ( starred ? starred_character : unstarred_character )
    class_name = ( starred ? "starred star" : "unstarred star" )
    content_tag( :span, character, :class => class_name, 
                 data: { unstarred_character: unstarred_character, starred_character: starred_character } )
  end

  def starred_character
    "&#9733;".html_safe
  end

  def unstarred_character
    "&#9734;".html_safe
  end

end
