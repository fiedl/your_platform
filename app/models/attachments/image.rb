class Attachments::Image < Attachment

  def thumb_url
    AppVersion.root_url + thumb_path
  end
  def thumb_path
    file.url(:thumb) || helpers.image_path('file.png')
  end

  def medium_url
    AppVersion.root_url + medium_path
  end
  def medium_path
    file.url(:medium)
  end

  def big_url
    AppVersion.root_url + big_path
  end
  def big_path
    file.url(:big)
  end

end