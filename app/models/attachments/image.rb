class Attachments::Image < Attachment

  def thumb_url
    AppVersion.root_url + (file.url(:thumb) || helpers.image_path('file.png'))
  end

  def medium_url
    AppVersion.root_url + file.url(:medium)
  end

  def big_url
    AppVersion.root_url + file.url(:big)
  end

end