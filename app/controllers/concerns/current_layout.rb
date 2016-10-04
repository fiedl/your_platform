concern :CurrentLayout do

  included do
    layout :current_layout

    helper_method :current_logo_url
    helper_method :current_layout
  end

  def current_layout
    #layout = (permitted_layouts & [layout_setting]).first
    layout ||= mobile_layout_if_mobile_app
    layout ||= (permitted_layouts & [params[:layout]]).first
    layout ||= current_navable.layout if current_navable.respond_to? :layout
    layout ||= default_layout
    return (permitted_layouts & [layout]).first
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
    %w(bootstrap minimal compact iweb mobile)
  end

  def default_layout
    'bootstrap'
  end

  def current_logo_url
    #current_navable.nav_node.breadcrumb_root
    Attachment.logos.first.try(:file).try(:url)
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

end