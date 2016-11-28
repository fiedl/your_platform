class Mobile::DashboardController < ApplicationController

  def index
    authorize! :read, :mobile_dashboard

    set_current_title "Vademecum"
    @events = current_user.upcoming_events.limit(5)
  end


  private

  def current_layout
    cookies[:layout] = 'mobile'
  end

end