class Mobile::AppInfoController < ApplicationController

  def index
    authorize! :read, :mobile_app_info

    set_current_title "App-Info"
  end

end