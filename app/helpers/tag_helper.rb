module TagHelper

  def tag_links_for(taggable)
    taggable.tags.collect { |tag| link_to_tag(tag) }.join(", ").html_safe
  end

  def link_to_tag(tag)
    link_to tag.name, tag_path(tag_name: tag.name)
  end

  def insert_links_into_tag_list(tag_list)
    tag_list = tag_list.split(",") if tag_list.kind_of? String
    tag_list.collect { |tag_name|
      tag_name = tag_name.strip
      link_to tag_name, Rails.application.routes.url_helpers.tag_path(tag_name: tag_name)
    }.join(", ").html_safe
  end

end
