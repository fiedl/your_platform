module TagHelper

  def tag_links_for(taggable)
    taggable.tags.collect { |tag| link_to_tag(tag) }.join(", ").html_safe
  end

  def link_to_tag(tag)
    link_to tag.name, tag_path(tag_name: tag.name)
  end

end