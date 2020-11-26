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

  def list_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-list" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <line x1="9" y1="6" x2="20" y2="6" />
        <line x1="9" y1="12" x2="20" y2="12" />
        <line x1="9" y1="18" x2="20" y2="18" />
        <line x1="5" y1="6" x2="5" y2="6.01" />
        <line x1="5" y1="12" x2="5" y2="12.01" />
        <line x1="5" y1="18" x2="5" y2="18.01" />
      </svg>
    }.html_safe
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
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-calendar" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <rect x="4" y="5" width="16" height="16" rx="2" />
        <line x1="16" y1="3" x2="16" y2="7" />
        <line x1="8" y1="3" x2="8" y2="7" />
        <line x1="4" y1="11" x2="20" y2="11" />
        <line x1="11" y1="15" x2="12" y2="15" />
        <line x1="12" y1="15" x2="12" y2="18" />
      </svg>
    }.html_safe
  end

  def event_icon
    fa_icon('calendar-check-o')
  end

  def time_icon
    fa_icon('clock-o')
  end

  def history_icon
    time_icon
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

  def user_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-user" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <circle cx="12" cy="7" r="4" />
        <path d="M6 21v-2a4 4 0 0 1 4 -4h4a4 4 0 0 1 4 4v2" />
      </svg>
    }.html_safe
  end

  def group_icon
    #fa_icon "group"
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-users" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <circle cx="9" cy="7" r="4" />
        <path d="M3 21v-2a4 4 0 0 1 4 -4h4a4 4 0 0 1 4 4v2" />
        <path d="M16 3.13a4 4 0 0 1 0 7.75" />
        <path d="M21 21v-2a4 4 0 0 0 -3 -3.85" />
      </svg>
    }.html_safe
  end

  def mail_icon
    #fa_icon "envelope"
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-mail" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <rect x="3" y="5" width="18" height="14" rx="2" />
        <polyline points="3 7 12 13 21 7" />
      </svg>
    }.html_safe
  end

  def network_icon
    fa_icon "share-alt"
  end

  def home_icon
    Haml::Engine.new(
    %Q(%svg.icon{:fill => "none", :height => "24", :stroke => "currentColor", "stroke-linecap" => "round", "stroke-linejoin" => "round", "stroke-width" => "2", :viewbox => "0 0 24 24", :width => "24", :xmlns => "http://www.w3.org/2000/svg"}
      %path{:d => "M0 0h24v24H0z", :stroke => "none"}
      %polyline{:points => "5 12 3 12 12 3 21 12 19 12"}
      %path{:d => "M5 12v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2 -2v-7"}
      %path{:d => "M9 21v-6a2 2 0 0 1 2 -2h2a2 2 0 0 1 2 2v6"}
    )).render
  end

  def contact_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-device-mobile" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <rect x="7" y="4" width="10" height="16" rx="1" />
        <line x1="11" y1="5" x2="13" y2="5" />
        <line x1="12" y1="17" x2="12" y2="17.01" />
      </svg>
    }.html_safe
  end

  def smartphone_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-device-mobile" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <rect x="7" y="4" width="10" height="16" rx="1" />
        <line x1="11" y1="5" x2="13" y2="5" />
        <line x1="12" y1="17" x2="12" y2="17.01" />
      </svg>
    }.html_safe
  end

  def landline_icon
    fa_icon 'phone'
  end

  def phone_icon
    smartphone_icon
  end

  def descending_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-sort-descending" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <line x1="4" y1="6" x2="13" y2="6" />
        <line x1="4" y1="12" x2="11" y2="12" />
        <line x1="4" y1="18" x2="11" y2="18" />
        <polyline points="15 15 18 18 21 15" />
        <line x1="18" y1="6" x2="18" y2="18" />
      </svg>
    }.html_safe
  end

  def ascending_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-sort-ascending" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <line x1="4" y1="6" x2="11" y2="6" />
        <line x1="4" y1="12" x2="11" y2="12" />
        <line x1="4" y1="18" x2="13" y2="18" />
        <polyline points="15 9 18 6 21 9" />
        <line x1="18" y1="6" x2="18" y2="18" />
      </svg>
    }.html_safe
  end

  def check_icon
    fa_icon 'check'
  end

  def camera_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-camera" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <path d="M5 7h1a2 2 0 0 0 2 -2a1 1 0 0 1 1 -1h6a1 1 0 0 1 1 1a2 2 0 0 0 2 2h1a2 2 0 0 1 2 2v9a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2v-9a2 2 0 0 1 2 -2" />
        <circle cx="12" cy="13" r="3" />
      </svg>
    }.html_safe
  end

  def time_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-clock" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <circle cx="12" cy="12" r="9" />
        <polyline points="12 7 12 12 15 15" />
      </svg>
    }.html_safe
  end

  def location_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-map-pin" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <circle cx="12" cy="11" r="3" />
        <path d="M17.657 16.657L13.414 20.9a1.998 1.998 0 0 1 -2.827 0l-4.244-4.243a8 8 0 1 1 11.314 0z" />
      </svg>
    }.html_safe
  end

  def plus_icon
    fa_icon 'plus'
  end

  def tag_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-tag" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <path d="M11 3L20 12a1.5 1.5 0 0 1 0 2L14 20a1.5 1.5 0 0 1 -2 0L3 11v-4a4 4 0 0 1 4 -4h4" />
        <circle cx="9" cy="9" r="2" />
      </svg>
    }.html_safe
  end

  def website_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-brand-safari" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <polyline points="8 16 10 10 16 8 14 14 8 16" />
        <circle cx="12" cy="12" r="9" />
      </svg>
    }.html_safe
  end

  def preview_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-eye" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <circle cx="12" cy="12" r="2" />
        <path d="M2 12l1.5 2a11 11 0 0 0 17 0l1.5 -2" />
        <path d="M2 12l1.5 -2a11 11 0 0 1 17 0l1.5 2" />
      </svg>
    }.html_safe
  end

  def tools_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-tools" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <path d="M3 21h4l13 -13a1.5 1.5 0 0 0 -4 -4l-13 13v4" />
        <line x1="14.5" y1="5.5" x2="18.5" y2="9.5" />
        <polyline points="12 8 7 3 3 7 8 12" />
        <line x1="7" y1="8" x2="5.5" y2="9.5" />
        <polyline points="16 12 21 17 17 21 12 16" />
        <line x1="16" y1="17" x2="14.5" y2="18.5" />
      </svg>
    }.html_safe
  end

  def facebook_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-brand-facebook" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <path d="M7 10v4h3v7h4v-7h3l1 -4h-4v-2a1 1 0 0 1 1 -1h3v-4h-3a5 5 0 0 0 -5 5v2h-3" />
      </svg>
    }.html_safe
  end

  def instagram_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-brand-instagram" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <rect x="4" y="4" width="16" height="16" rx="4" />
        <circle cx="12" cy="12" r="3" />
        <line x1="16.5" y1="7.5" x2="16.5" y2="7.501" />
      </svg>
    }.html_safe
  end

  def youtube_icon
    fa_icon :youtube
  end

  def send_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-send" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <line x1="10" y1="14" x2="21" y2="3" />
        <path d="M21 3L14.5 21a.55 .55 0 0 1 -1 0L10 14L3 10.5a.55 .55 0 0 1 0 -1L21 3" />
      </svg>
    }.html_safe
  end

  def inbox_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-inbox" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <rect x="4" y="4" width="16" height="16" rx="2" />
        <path d="M4 13h3l3 3h4l3 -3h3" />
      </svg>
    }.html_safe
  end

  def info_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-info-circle" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <circle cx="12" cy="12" r="9" />
        <line x1="12" y1="8" x2="12.01" y2="8" />
        <polyline points="11 12 12 12 12 16 13 16" />
      </svg>
    }.html_safe
  end

  def calendar_plus_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-calendar-plus" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <rect x="4" y="5" width="16" height="16" rx="2" />
        <line x1="16" y1="3" x2="16" y2="7" />
        <line x1="8" y1="3" x2="8" y2="7" />
        <line x1="4" y1="11" x2="20" y2="11" />
        <line x1="10" y1="16" x2="14" y2="16" />
        <line x1="12" y1="14" x2="12" y2="18" />
      </svg>
    }.html_safe
  end

  def calendar_minus_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-calendar-minus" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <rect x="4" y="5" width="16" height="16" rx="2" />
        <line x1="16" y1="3" x2="16" y2="7" />
        <line x1="8" y1="3" x2="8" y2="7" />
        <line x1="4" y1="11" x2="20" y2="11" />
        <line x1="10" y1="16" x2="14" y2="16" />
      </svg>
    }.html_safe
  end

  def comments_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-message" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z"/>
        <path d="M4 21v-13a3 3 0 0 1 3 -3h10a3 3 0 0 1 3 3v6a3 3 0 0 1 -3 3h-9l-4 4" />
        <line x1="8" y1="9" x2="16" y2="9" />
        <line x1="8" y1="13" x2="14" y2="13" />
      </svg>
    }.html_safe
  end

  def download_icon
    %q{
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-download" width="44" height="44" viewBox="0 0 24 24" stroke-width="1.5" stroke="#2c3e50" fill="none" stroke-linecap="round" stroke-linejoin="round">
        <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
        <path d="M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2 -2v-2" />
        <polyline points="7 11 12 16 17 11" />
        <line x1="12" y1="4" x2="12" y2="16" />
      </svg>
    }.html_safe
  end

end