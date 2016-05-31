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

end