class Api::V1::EventsController < Api::V1::BaseController

  def index
    authorize! :index, Event

    if params[:public]
      @events = Event.where(publish_on_global_website: true)
    elsif params[:all]
      @events = Event.all
    else
      @events = current_user.events
    end

    if params[:with_recent]
      @events = @events.where('start_at > ?', 3.months.ago)
    elsif params[:upcoming]
      @events = @events.upcoming
    end

    @events = @events.order 'events.start_at, events.created_at'
    @events = @events.select { |event| can? :read, event }

    render json: @events.as_json(methods: [:avatar_url, :group_name, :corporation_name, :contact_name, :contact_id])
  end

end
