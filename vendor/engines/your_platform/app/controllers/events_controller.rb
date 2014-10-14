class EventsController < ApplicationController

  load_and_authorize_resource
  skip_authorize_resource only: [:index, :create]

  # GET /events
  # GET /events.json
  #
  # ATTENTION: The index action has to handly authorization manually!
  #
  def index
    
    # Which events should be listed
    @group = Group.find params[:group_id] if params[:group_id]
    @user = Group.find params[:user_id] if params[:user_id]
    @user ||= current_user
    @user ||= UserAccount.find_by_auth_token(params[:token]).try(:user) if params[:token].present?
    @all = params[:all]
    @on_local_website = params[:published_on_local_website]
    @on_global_website = params[:published_on_global_website]
    @public = @on_local_website || @on_global_website
    
    # Check the permissions.
    if @all and not @public
      authorize! :index_events, :all
    elsif @all and @public
      authorize! :index_public_events, :all
    elsif @group
      @public ? authorize!(:index_public_events, :all) : authorize!(:index_events, @group)
    elsif @user
      authorize! :index_events, @user
    end  
    
    # Collect the events to list.
    if @all
      @events = Event.where(true)
    elsif @group
      @events = Event.find_all_by_group(@group)
      @navable = @group
    elsif @user
      @events = Event.find_all_by_user(@user)
      @navable = @user
    end
    
    # Filter if only published events are requested.
    @events = @events.where publish_on_local_website: true if @on_local_website
    @events = @events.where publish_on_global_website: true if @on_global_website
    
    # Order events
    @events = @events.order :start_at
    
    # Add the Cross-origin resource sharing header for public requests.
    response.headers['Access-Control-Allow-Origin'] = '*' if @public

    respond_to do |format|
      format.html do
        if @on_local_website or @on_global_website
          render partial: 'events/public_index', locals: {events: @events}
        else
          # index.html.haml
        end
      end
      format.json { render json: @events }
      format.ics { send_data @events.to_ics, filename: "#{@group.try(:name)} #{Time.zone.now}".parameterize + ".ics" }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @navable = @event
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
      format.ics { render text: @event.to_ics }
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
    
    @event = Event.new(params[:event])
    @event.name ||= I18n.t(:enter_name_of_event_here)
    @event.start_at ||= Time.zone.now.change(hour: 20, min: 15)
    
    respond_to do |format|
      if @event.save
        @event.parent_groups << @group
        @event.contact_people << current_user
        @event[:path] = event_path(@event) # in order to add the path to the json object
        
        format.html { redirect_to @event }
        format.json { render json: @event, status: :created, location: @event }
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
      if @event.update_attributes!(params[:event])
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
      format.html { redirect_to events_url }
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
    # Only allow GET from email links.
    if params[:email_confirm] == 'true'
      join
    else
      redirect_to Event.find(params[:event_id])
    end
  end
  
  def change_attendance(join = true)
    @event = Event.find params[:event_id]
    authorize! :join, @event

    if join
      @event.attendees_group.assign_user current_user, at: Time.zone.now
    else
      @event.attendees_group.child_users.destroy(current_user)
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
    authorize! :update, @event
    
    @text = params[:text]
    @recipients = []
    
    if params['recipient'] == 'me'
      @recipients = [current_user]
    elsif params['recipient'].kind_of? Integer
      group = Group.find params['recipient']
      @recipients = group.members
    end
    
    EventMailer.invitation_email(@text, @recipients, @event, current_user).deliver
    
    respond_to do |format|
      format.html { redirect_to event_url(@event) }
      format.json { head :no_content }
    end
  end
  
end
