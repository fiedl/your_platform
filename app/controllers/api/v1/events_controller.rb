class Api::V1::EventsController < Api::V1::BaseController

  def index
    authorize! :index, Event

    if params[:public]
      @events = Event.upcoming.where(publish_on_global_website: true)
    else
      @events = current_user.upcoming_events
    end
    @events = @events.order 'events.start_at, events.created_at'
    @events = @events.select { |event| can? :read, event }

    render json: @events.as_json
  end

end
