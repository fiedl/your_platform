class Mobile::DashboardController < ApplicationController
  layout -> { 'mobile' }

  def index
    authorize! :read, :dashboard

    set_current_title "Vademecum"
  end


end