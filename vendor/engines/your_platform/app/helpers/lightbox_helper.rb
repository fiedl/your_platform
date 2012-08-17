module LightboxHelper

  def attachment_lightbox_tag( attachment, html_options = {} )
    ( lightbox_tag( attachment.thumb_url,
                    attachment.file_url,
                    lightbox_title( attachment ),
                    "gallery" )
      ).html_safe
  end

  private

  def lightbox_title( attachment )
    in_place_title( attachment ) + "\n" + in_place_description( attachment )
  end

  def in_place( attachment, attribute )
    best_in_place_tag = best_in_place( attachment, attribute )
    best_in_place_tag.gsub!( "\"", "'" ) # since the html tag will look like this:
                                         #   <... title="<span class='best_in_place' ...>">
    return best_in_place_tag
  end

  def in_place_title( attachment )
    in_place( attachment, :title )
  end
  def in_place_description( attachment )
    in_place( attachment, :description )
  end

end
