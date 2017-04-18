module IconHelper

  def icon(icon_key)
    if icon_key.to_s.in? ['beer', 'coffee', 'key', 'lock', 'unlock', 'unlock-alt', 'archive', 'undo', 'history', 'folder-open', 'sort-alpha-asc', 'sort-numeric-asc', 'sort-numeric-desc']
      awesome_icon(icon_key)
    else
      glyphicon(icon_key.to_s.gsub('glyphicon-', ''))
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

  def excel_icon
    image_tag 'img/excel2013_file_bw_semitransparent_107.png', height: 16
  end

  def xls_icon
    excel_icon
  end

  def csv_icon
    icon 'list-alt'
  end

  def folder_icon
    fa_icon 'folder-open-o'
  end

  def settings_icon
    fa_icon 'sliders' # cogs, wrench
  end

  def create_icon
    fa_icon 'plus-circle'
  end

  def rss_icon
    fa_icon 'rss'
  end

  def attachment_icon
    awesome_icon(:paperclip)
  end

end