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

end