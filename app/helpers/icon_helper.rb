module IconHelper

  def icon(icon_key)
    if icon_key.to_s.in? ['beer', 'coffee', 'key', 'lock', 'unlock', 'unlock-alt', 'archive', 'undo', 'history', 'folder-open', 'sort-alpha-asc', 'sort-numeric-asc', 'sort-numeric-desc']
      awesome_icon(icon_key)
    else
      fa(icon_key.to_s.gsub('fa-', ''))
    end
  end

  # This includes an icon from Twitter-Bootstrap's Glyphicon icon set:
  # http://getbootstrap.com/components/#fas
  #
  def fa(icon_key)
    content_tag :span, '', class: "fa fa-#{icon_key}", 'aria-hidden' => true
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
  def fa_icon(icon_key)
    content_tag :i, '', class: "fa fa-#{icon_key} #{icon_key}"
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

  def help_icon
    icon 'question-sign'
  end

  def settings_icon
    fa_icon 'sliders' # cogs, wrench  # icon 'cog'
  end

  def folder_icon
    fa_icon 'folder-open-o'
  end

  def document_icon
    fa_icon 'file-o'
  end

  def create_icon
    fa_icon 'plus-circle'
  end

  def rss_icon
    fa_icon 'rss'
  end

  def podcast_icon
    fa_icon 'podcast'
  end

  def attachment_icon
    awesome_icon(:paperclip)
  end

  def calendar_icon
    fa_icon(:calendar)
  end

  def event_icon
    fa_icon('calendar-check-o')
  end

  def time_icon
    fa_icon('clock-o')
  end

  def edit_icon
    icon :edit
  end

  def trash_icon
    icon :trash
  end

  def signature_icon
    fa_icon 'pencil-square-o'
  end

  def publish_icon
    fa_icon 'cloud-upload'
  end

  def move_icon
    fa_icon 'arrow-circle-o-right'
  end

  def relocation_icon
    move_icon
  end

  def search_icon
    fa_icon 'search'
  end

  def discourse_icon
    fa_icon "discourse"
  end

  def github_icon
    fa_icon "github"
  end

  def trello_icon
    fa_icon "trello"
  end

end