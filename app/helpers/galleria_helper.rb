module GalleriaHelper
  
  def attachment_galleria_image_tag( attachment )
    image_tag attachment.medium_url, data: {
      thumb: attachment.thumb_url,
      big: attachment.file_url,
      title: attachment.title,
      description: attachment.description,
      #link: attachment.file_url,
    }
  end
  
end