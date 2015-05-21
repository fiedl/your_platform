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
  
end