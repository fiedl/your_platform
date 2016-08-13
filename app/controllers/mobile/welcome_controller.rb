class Mobile::WelcomeController < ApplicationController

  def index
    authorize! :read, :mobile_welcome

    if current_user
      redirect_to mobile_dashboard_path
    else
      set_current_title "Vademecum"
      session['return_to_after_login'] = mobile_dashboard_path
    end
  end

  private

  def find_layout
    cookies[:layout] = 'mobile'
  end

end