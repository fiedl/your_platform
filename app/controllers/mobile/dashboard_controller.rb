class Mobile::DashboardController < Mobile::BaseController

  def index
    authorize! :read, :mobile_dashboard

    unless beta.invitees.include? current_user
      redirect_to mobile_beta_path
    end

    set_current_title "Vademecum"
    @events = current_user.upcoming_events.limit(5)
    @all_event_images = current_user.event_images
    @latest_event_images = current_user.event_images.last(5)
  end


  private

  def current_layout
    cookies[:layout] = 'mobile'
  end

end