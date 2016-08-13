class Mobile::DashboardController < ApplicationController

  def index
    authorize! :read, :dashboard

    set_current_title "Vademecum"
    @events = current_user.upcoming_events.limit(5)

  end


  private

  def find_layout
    cookies[:layout] = 'mobile'
  end

end