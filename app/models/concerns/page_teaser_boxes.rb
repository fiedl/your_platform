concern :PageTeaserBoxes do

  def child_teaser_boxes
    teaser_boxes
  end

  def teaser_boxes
    # # For some reason, this does not work: FIXME
    # child_pages
    #   .where.not(type: 'BlogPost')
    #   .where.not(nav_nodes: {hidden_teaser_box: true})
    #
    child_pages
      .select { |page| not page.type.in? ['BlogPost'] }
      .select { |page| not page.embedded? }
      .select { |page| not page.nav_node.hidden_teaser_box }
      .select { |page| not page.new_record? }
  end

  def teaser_text
    super || if content
      paragraphs = content
        .gsub(teaser_youtube_url.to_s, '')
        .gsub(/\n[ ]*\n/, "\n\n").split("\n\n")
      teaser_content = paragraphs.first
      teaser_content += "\n\n" + paragraphs.second if teaser_content.to_s.start_with?("http") # For inline videos etc.
      teaser_content
    end
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
    image_attachments.map(&:medium_url) + if content.present?
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

end