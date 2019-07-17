module GalleriaHelper

  def galleria(options = {})
    options[:theme] ||= 'classic'
    options[:theme_js] ||= asset_path("galleria-#{options[:theme]}.js")
    content_tag :div, class: 'galleria', data: {theme_js_path: options[:theme_js]} do
      yield
    end
  end

  def attachment_galleria_image_tag(attachment)
    # See: http://galleria.io/docs/references/data/#separate-thumbnails
    link_to attachment.medium_path do
      image_tag attachment.thumb_url, data: {
        image: attachment.medium_path,
        thumb: attachment.thumb_path,
        medium: attachment.medium_path,
        big: attachment.big_path,
        title: attachment.title,
        description: attachment.description,
        height: attachment.height,
        width: attachment.width
        #link: attachment.file_url,
      }
    end
  end

  def video_gallery(video_url)
    content_tag :div, class: 'wysihtml-uneditable-container for-video-gallery', contenteditable: false do
      content_tag :div, class: 'galleria video-gallery', data: {video_url: video_url, theme_js_path: asset_path('galleria-classic.js'), you_tube_api_key: Rails.application.secrets.you_tube_api_key} do
        content_tag :a, href: video_url do
          content_tag :span, class: 'video' do
            "Video"
          end
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
