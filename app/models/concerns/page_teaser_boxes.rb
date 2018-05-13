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
    super || content_without_video_url.to_s.split("\n\n").first
  end

  def content_without_video_url
    content.to_s
      .gsub(teaser_youtube_url.to_s, '')
      .gsub(teaser_video_url.to_s, '')
      .gsub(/\n[ ]*\n/, "\n\n")
      .gsub(/\A\n\n/, "")
  end

end