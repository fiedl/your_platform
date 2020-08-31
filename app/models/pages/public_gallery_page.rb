class Pages::PublicGalleryPage < Pages::PublicPage

  def images
    self.image_attachments
  end

end