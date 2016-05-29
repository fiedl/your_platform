concern :CurrentLayout do

  included do
    layout :current_layout
  end

  def current_layout
    layout = (permitted_layouts & [layout_setting]).first
    layout ||= current_navable.layout if current_navable.respond_to? :layout
    layout ||= "bootstrap"
    return layout
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
    %w(bootstrap minimal compact iweb)
  end

end