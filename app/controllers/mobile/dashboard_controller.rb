class Mobile::DashboardController < ApplicationController

  def index
    authorize! :read, :mobile_dashboard

    set_current_title "Vademecum"

  end


  private

  def find_layout
    cookies[:layout] = 'mobile'
  end

end