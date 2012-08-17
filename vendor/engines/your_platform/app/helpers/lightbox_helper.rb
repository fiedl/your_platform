module LightboxHelper

  def attachment_lightbox_tag( attachment, html_options = {} )
    ( lightbox_tag( attachment.thumb_url,
                    attachment.file_url,
                    lightbox_title( attachment ),
                    "gallery" )
      ).html_safe
  end

  def lightbox_title( attachment )
    attachment.title + "\n" + attachment.description
  end

end
