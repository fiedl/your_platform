class AppSettingsController < ApplicationController

  def index
    authorize! :manage, :app_settings

    set_current_title t(:app_settings)

    @root_page = Page.find_or_create_root
    @logo_page = Page.where(title: 'Logo').first_or_create
  end

end