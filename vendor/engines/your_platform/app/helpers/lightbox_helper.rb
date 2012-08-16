module LightboxHelper

  def attachment_lightbox_tag( attachment, html_options = {} )
    ( lightbox_tag( attachment.thumb_url,
                    attachment.file_url,
                    best_in_place( attachment, :title ) + "<br />" + best_in_place( attachment, :description ),
                    "gallery" ) +
      #                  attachment.title + "<br />" + attachment.description )
      show_only_in_edit_mode_span do
        best_in_place( attachment, :title ) + "<br />" + best_in_place( attachment, :description ) +
          "<br clear='all'>"
      end
      ).html_safe

  end

end
