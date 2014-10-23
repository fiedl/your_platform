class EventsController < ApplicationController

  load_and_authorize_resource
  skip_authorize_resource only: [:index, :create, :join_via_get]

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
    @limit = params[:limit].to_i
    
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
    @events = @events.order events: [:start_at, :created_at]
    
    # Limit the number of events
    @events = @events.limit(@limit) if @limit && @limit > 0
    
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
    
    if @group
      @event = @group.child_events.new(params[:event])
    else
      Event.new(params[:event])
    end
    @event.name ||= I18n.t(:enter_name_of_event_here)
    @event.start_at ||= Time.zone.now.change(hour: 20, min: 15)
    
    respond_to do |format|
      if @event.save
        
        # Attention: The save call will call some callbacks, which might cause
        # one of the following calls to run into sql deadlock issues.
        # ActiveRecord of Rails 3 does not resolve these issues.
        # Therefore, we use the transaction_retry gem, which retries the
        # call after running into locked records.
        # 
        # TODO: This needs to be carefully checked when we migrate to Rails 4,
        # since the locking behaviour might have changed. The transaction_retry
        # gem has been updated last in 2012!
        #
        @event.reload
        @event.create_attendees_group
        @event.create_contact_people_group
        @event.contact_people_group.assign_user current_user, at: 2.seconds.ago
        
        # To avoid `ActiveRecord::RecordNotFound` after the redirect, we have to
        # make sure the record can be found.
        #
        # TODO: Check if this is really necessary in Rails 4 anymore.
        #
        begin 
          @event = Event.find(@event)
        rescue ActiveRecord::RecordNotFound => e
          sleep 1
          retry
        end
        
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
    authorize! :update, @event
    
    @text = params[:text]
    @recipients = []
    
    if params['recipient'] == 'me'
      @recipients = [current_user]
    elsif params['recipient'].to_i > 0
      group = Group.find params['recipient'].to_i
      @recipients = group.members
    end
    
    for recipient in @recipients
      EventMailer.invitation_email(@text, [recipient], @event, current_user).deliver
    end
    
    respond_to do |format|
      format.html { redirect_to event_url(@event) }
      format.json { head :no_content }
    end
  end
  
end
