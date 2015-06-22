module IconHelper
  
  def icon(icon_key)
    if icon_key.to_s.in? ['beer', 'coffee', 'key', 'lock', 'unlock', 'unlock-alt']
      awesome_icon(icon_key)
    else
      glyphicon(icon_key)
    end
  end
  
  # This includes an icon from Twitter-Bootstrap's Glyphicon icon set:
  # http://getbootstrap.com/components/#glyphicons
  #
  def glyphicon(icon_key)
    content_tag :span, '', class: "glyphicon glyphicon-#{icon_key}", 'aria-hidden' => true
  end
  
  # This includes an icon from the Font-Awesome icon set:
  # http://fortawesome.github.io/Font-Awesome/icons/
  # 
  # This inserts something like
  #     <i class="fa fa-beer fa-2x"></i>
  #
  def awesome_icon(icon_key)
    # This helper is defined in:
    # https://github.com/bokmann/font-awesome-rails
    
    fa_icon icon_key if defined?(fa_icon)  # it's not defined in mailers.
  end
  
  def large_awesome_icon(icon_key)
    fa_icon "#{icon_key} 2x"
  end

end