concern :CurrentLayout do

  included do
    layout :current_layout

    before_action :prepend_layout_view_path

    helper_method :current_layout
    helper_method :resource_centred_layout?
    helper_method :permitted_layouts

    helper_method :current_logo_url
    helper_method :current_logo
    helper_method :default_logo
  end

  def current_layout
    layout ||= (permitted_layouts & [layout_param]).first
    #layout ||= (permitted_layouts & [layout_setting]).first if current_navable.try(:in_intranet?)
    #layout ||= mobile_layout_if_mobile_app
    #layout ||= intranet_layout if current_navable.try(:in_intranet?)
    #layout ||= current_navable.layout if current_navable.respond_to? :layout
    #layout ||= current_home_page.layout if current_home_page
    layout ||= default_layout
    return (permitted_layouts & [layout]).first
  end

  def layout_param
    save_layout_setting_as_cookie unless @layout_setting
    @layout_setting ||= params[:layout]
  end

  def layout_setting
    save_layout_setting_as_cookie unless @layout_setting
    @layout_setting ||= params[:layout] || cookies[:layout]
  end

  def save_layout_setting_as_cookie
    cookies[:layout] = params[:layout] if params[:layout]
    cookies[:layout]
  end

  def permitted_layouts
    ([default_layout] + %w(bootstrap minimal compact modern iweb mobile resource_2017 primer strappy)).uniq
  end

  def default_layout
    'strappy'
  end

  def intranet_layout
    'strappy'
  end

  def current_logo_url(key = nil)
    current_logo(key).try(:file).try(:url)
  end

  def current_logo(key = nil)
    logos = if current_home_page
      Attachment.where(parent_type: 'Page', parent_id: [current_home_page.id] + current_home_page.child_pages.pluck(:id)).logos
    else
      Attachment.none
    end
    logos = Attachment.logos if logos.none?
    logos = logos.where(title: key) if key
    logos.last
  end

  def default_logo
    'logo.png'
  end

  def resource_centred_layouts
    %w(resource_2017 primer)
  end

  def resource_centred_layout?
    current_layout.in? resource_centred_layouts
  end

  # The mobile app appends the parameter `?layout=mobile` once.
  # After that, the layout has to stay mobile. We use a cookie
  # to store that. As the mobile app has its own cookie store,
  # this won't interfere with other platform client instances.
  #
  def mobile_layout_if_mobile_app
    cookies[:layout] = 'mobile' if params[:layout] == 'mobile'
    if cookies[:layout] == 'mobile' and (params[:layout].blank? or params[:layout] == 'mobile')
      'mobile'
    else
      nil
    end
  end

  # Each layout may define override views.
  # When using the layout `foo`, the view
  #
  #     app/views/foo/pages/show.html.haml
  #
  # takes precedence over the usual:
  #
  #     app/views/pages/show.html.haml
  #
  def prepend_layout_view_path
    prepend_view_path YourPlatform::Engine.root.join("app/views/#{current_layout}").to_s
  end

end