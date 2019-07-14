class EventsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :wait_for_existance

  load_and_authorize_resource except: [:invite]
  skip_authorize_resource only: [:index, :create, :join_via_get]

  # GET /events
  # GET /events.json
  #
  # ATTENTION: The index action has to handly authorization manually!
  #
  def index
    @group = Group.includes(
      :parent_groups,
      :parent_pages,
      :parent_events,
      :nav_node
    ).find params[:group_id] if params[:group_id]

    # Which events should be listed
    @all = params[:all]
    @on_local_website = params[:published_on_local_website]
    @on_global_website = params[:published_on_global_website]
    @public = @on_local_website || @on_global_website
    @limit = params[:limit].to_i

    # Show semetser calendars for corporations
    if (! @public) && request.format.html? && can?(:use, :semester_calendars) && @group.kind_of?(Corporation)
      authorize! :index_public_events, @group
      redirect_to group_search_semester_calendar_path(group_id: @group.id)
      return
    end

    # Which events, part ii: Events for a certain user:
    @user = User.find params[:user_id] if params[:user_id]
    @user ||= current_user
    @user ||= UserAccount.find_by_auth_token(params[:token]).try(:user) if params[:token].present?

    # Check the permissions.
    if @group
      @public ? authorize!(:index_public_events, :all) : authorize!(:index_events, @group)
    elsif @user
      authorize! :index_events, @user
    elsif @all and not @public
      authorize! :index_events, :all
    elsif @all and @public
      authorize! :index_public_events, :all
    else
      unauthorized!
    end

    # Collect the events to list.
    if @group
      @events = Event.find_all_by_group(@group)
      set_current_navable @group
    elsif @user
      @events = @user.events
      set_current_navable @user
    elsif @all
      @events = Event.all
    end

    # Filter if only published events are requested.
    @events = @events.where publish_on_local_website: true if @on_local_website
    @events = @events.where publish_on_global_website: true if @on_global_website

    # Preload groups
    @events = @events.includes(:parent_groups, :child_groups)

    # Order events
    @events = @events.order 'events.start_at, events.created_at'

    # Limit the number of events.
    # If a limit exists, make sure to return upcoming events.
    @events = @events.upcoming.limit(@limit) if @limit && @limit > 0

    # Filter by access.
    @events = Event.where(id: @events.select { |event| can? :read, event }.pluck(:id))

    # Add the Cross-origin resource sharing header for public requests.
    response.headers['Access-Control-Allow-Origin'] = '*' if @public

    respond_to do |format|
      format.html do
        if @on_local_website or @on_global_website
          render partial: 'events/public_index', locals: {events: @events}
        else
          if @group
            cookies[:group_tab] = "events"
            set_current_activity :is_looking_at_the_group_calendar, @group
            set_current_access :signed_in
            set_current_access_text :all_signed_in_users_can_read_these_group_events
          else
            set_current_activity :is_looking_at_events
          end
          # renders "index.html.haml"
        end
      end
      format.json { render json: @events }
      format.ics do
        @user.try(:grant_badge, 'calendar-uplink')
        send_data @events.to_ics, filename: "#{@group.try(:name)} #{Time.zone.now}".parameterize + ".ics"
      end
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    set_current_navable @event

    respond_to do |format|
      format.html do
        set_current_activity :is_looking_at_the_event, @event
        set_current_access :signed_in
        set_current_access_text :all_signed_in_users_can_read_this_event_and_can_join
        # show.html.erb
      end
      format.json { render json: @event }
      format.ics { render plain: @event.to_ics }
    end
  end

  # POST /events
  # POST /events.json
  #
  # ATTENTION: The create action has to handly authorization manually!
  #
  def create
    @group = Group.find(params[:group_id])
    authorize! :create_event, @group

    @event = Event.new(event_params)
    @event.name ||= I18n.t(:enter_name_of_event_here)
    @event.start_at ||= Time.zone.now.change(hour: 20, min: 15)
    @event.group = @group

    respond_to do |format|
      if @event.save
        @event.create_attendees_group
        @event.create_contact_people_group
        @event.contact_people_group.assign_user current_user, at: 2.seconds.ago

        set_current_activity :is_adding_an_event, @event

        format.html { redirect_to event_path(@event) }
        format.json { render json: @event.attributes.merge({path: event_path(@event)}), status: :created, location: @event }
      else
        format.html { redirect_to :back }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update_attributes!(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { respond_with_bip(@event) }
      else
        format.html { render action: "edit" }
        format.json { respond_with_bip(@event) }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end


  # POST /events/1/join
  def join
    change_attendance(true)
  end
  def leave
    change_attendance(false)
  end
  def join_via_get
    @event = Event.find params[:event_id]
    if params[:email_confirm] == 'true'  # Only allow GET from email links.
      authorize! :join, @event
      join
    else
      authorize! :read, @event
      redirect_to Event.find(params[:event_id])
    end
  end

  def change_attendance(join = true)
    @event = Event.find params[:event_id]
    authorize! :join, @event

    if join
      current_user.join @event
    else
      current_user.leave @event
    end

    respond_to do |format|
      format.html { redirect_to event_url(@event) }
      format.json do
        render json: {
          attendees_avatars: render_to_string(
            partial: 'groups/member_avatars',
            layout: false,
            formats: [:json, :html],
            handlers: [:haml],
            locals: {group: @event.attendees_group}
          )
        }
      end
    end
  end
  private :change_attendance


  # POST /events/:event_id/invite/:recipient
  # params:
  #   - recipient
  #   - text
  #   - event_id
  def invite
    @event = Event.find params[:event_id]
    authorize! :invite_to, @event

    @text = params[:text]
    @recipients = []

    if params['recipient'] == 'me'
      @recipients = [current_user]
    elsif params['recipient'].to_i > 0
      group = Group.find params['recipient'].to_i
      @recipients = group.members
    end

    @recipients.each do |recipient|
      if recipient.has_account? and not recipient.email_does_not_work?
        EventMailer.invitation_email(@text, [recipient], @event, current_user).deliver_later
      end
    end

    respond_to do |format|
      format.html { redirect_to event_url(@event) }
      format.json { head :no_content }
    end
  end

private

  def event_params
    params[:event].try(:permit, :description, :location, :end_at, :name, :start_at, :localized_start_at, :localized_end_at, :publish_on_local_website, :publish_on_global_website, :group_id, :contact_person_id) || {}
  end

  # For some strange reason, some ajax calls fail since the object is not yet
  # available to the other server instance. So, try a few times before giving up.
  #
  def wait_for_existance
    raise ActionController::ParameterMissing, "No id given. Params are: #{params.to_s}" unless params[:id] || params[:event_id]
    counter = 20
    begin
      sleep 0.5
      Event.find params[:id]
    rescue ActiveRecord::RecordNotFound => e
      counter -= 1
      retry until counter <= 0
    end
  end

end
