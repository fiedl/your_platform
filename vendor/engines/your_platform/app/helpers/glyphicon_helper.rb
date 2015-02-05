module GlyphiconHelper
  
  def icon(icon_key)
    glyphicon(icon_key)
  end

  def glyphicon(icon_key)
    content_tag :span, '', class: "glyphicon glyphicon-#{icon_key}", 'aria-hidden' => true
  end
  
end