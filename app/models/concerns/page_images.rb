concern :PageImages do

  def image_attachments
    attachments.find_by_type('image')
  end

  def image_attachments_not_listed_in_content
    image_attachments.select do |attachment|
      # Do not list images that are `![markdown-images](...)` within the
      # page content as attachments in order to avoid displaying them
      # twice.
      not self.content.try(:include?, attachment.file_path)
    end
  end

  # An array of teaser images of this page. The elements can be
  # Attachments or Strings with image urls.
  #
  def teaser_images
    @teaser_images ||= begin
      @teaser_images = ([primary_teaser_image_url] + image_urls_from_content + image_attachments_not_listed_in_content - [nil]).uniq
      @teaser_images = [auto_teaser_image] if @teaser_images.none? && auto_teaser_image
      @teaser_images
    end
  end

  def primary_teaser_image_url
    self.settings.teaser_image_url
  end

  def teaser_image_url
    if self.settings.teaser_image_url
      self.settings.teaser_image_url
    else
      possible_teaser_image_urls.first
    end
  end

  def teaser_image_url=(new_url)
    if new_url.present?
      self.settings.teaser_image_url = new_url
    else
      self.settings.teaser_image_url = nil
    end
  end

  def possible_teaser_image_urls
    image_attachments.map(&:big_url) + image_urls_from_content
  end

  def image_urls_from_content
    if content.present?
      URI.extract(content)
        .select{ |l| l[/\.(?:gif|png|jpe?g)\b/]}
        .collect { |url| url.gsub(")", "") } # to fix markdown image urls
    else
      []
    end
  end

  def teaser_youtube_url
    content.to_s.match(/(https?\:\/\/)?(www\.)?(youtube\.com|youtu\.?be)\/.+/).try(:[], 0)
  end

  def teaser_image?
    teaser_images.any? || teaser_youtube_url
  end

  def auto_teaser_image
    @auto_teaser_image ||= (available_auto_teaser_images[self.id % available_auto_teaser_images.count] if available_auto_teaser_images.any?)
  end

  def available_auto_teaser_images
    []
  end

end