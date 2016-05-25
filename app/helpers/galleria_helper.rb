module GalleriaHelper

  def attachment_galleria_image_tag(attachment)
    # See: http://galleria.io/docs/references/data/#separate-thumbnails
    link_to attachment.medium_url do
      image_tag attachment.thumb_url, data: {
        image: attachment.medium_url,
        thumb: attachment.thumb_url,
        medium: attachment.medium_url,
        big: attachment.big_url,
        title: attachment.title,
        description: attachment.description,
        #link: attachment.file_url,
      }
    end
  end

  def video_gallery(video_url)
    content_tag :div, class: 'galleria video-gallery', data: {theme_js_path: asset_path('galleria-classic.js'), you_tube_api_key: Rails.application.secrets.you_tube_api_key} do
      content_tag :a, href: video_url do
        content_tag :span, class: 'video' do
          "Video"
        end
      end
    end
  end

end

# In order to use the helper method with best_in_place's :display_with argument,
# the ActionView::Base has to include the method.
#
module ActionView
  class Base
    include GalleriaHelper
  end
end
