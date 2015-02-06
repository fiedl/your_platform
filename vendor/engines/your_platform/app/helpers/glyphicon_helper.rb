module GlyphiconHelper
  
  def icon(icon_key)
    if icon_key.to_s.in? ['beer', 'coffee']
      icon_key = "icon-#{icon_key}"
    end
    if icon_key.to_s.start_with? 'icon-'
      bootstrap2_icon(icon_key)
    else
      glyphicon(icon_key)
    end
  end

  def glyphicon(icon_key)
      content_tag :span, '', class: "glyphicon glyphicon-#{icon_key}", 'aria-hidden' => true
  end
  
  def bootstrap2_icon(icon_key)
    icon_key = "icon-#{icon_key}" unless icon_key.to_s.start_with? 'icon-'
    content_tag :i, '', class: "icon-large #{icon_key}"
  end
  
end