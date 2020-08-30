class Api::V1::EventsController < Api::V1::BaseController

  expose :event

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

    render json: @events.as_json(methods: required_event_methods)
  end

  def show
    authorize! :read, event

    render json: event.as_json(methods: required_event_methods)
  end

  expose :group, -> { Group.find params[:group_id] if params[:group_id].present? }
  expose :parent_groups, -> { Group.where(id: params[:parent_group_ids]) if params[:parent_group_ids] }
  expose :contact_people, -> { User.where(id: params[:contact_people_ids] || params[:event][:contact_people_ids]) if params[:contact_people_ids] || (params[:event] && params[:event][:contact_people_ids]) }

  def create
    authorize! :create, Event
    authorize! :create_event, group if group

    new_event = (group.try(:events) || Event).create! event_params
    new_event.parent_groups = parent_groups if parent_groups.present?
    new_event.contact_people = contact_people if contact_people.present?

    render json: new_event, status: :ok
  end

  def destroy
    authorize! :destroy, event
    event.destroy!
    render json: {}, status: :ok
  end

  def update
    authorize! :update, event
    event.update! event_params
    event.contact_people = contact_people if contact_people

    render json: event.as_json.merge({
      attendees_count: event.attendees.count
    }), status: :ok
  end

  private

  def required_event_methods
    [:avatar_url, :group_id, :group_name, :corporation_id, :corporation_name, :contact_name, :contact_id]
  end

  def event_params
    params.require(:event).permit(:name, :start_at, :publish_on_local_website, :publish_on_global_website, :location, :aktive, :philister)
  end

end
