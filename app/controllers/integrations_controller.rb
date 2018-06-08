class IntegrationsController < ApplicationController

  def index
    authorize! :index, :integrations

    set_current_navable Page.intranet_root
    set_current_breadcrumbs [
      {title: "App Settings", path: app_settings_path},
      {title: "Integrations", path: integrations_path}
    ]
    @hide_vertical_nav = true
  end

  def show
    set_current_navable Page.intranet_root
    @hide_vertical_nav = true

    set_current_breadcrumbs [
      {title: "App Settings", path: app_settings_path},
      {title: "Integrations", path: integrations_path},
      {title: current_title}
    ]
  end

end