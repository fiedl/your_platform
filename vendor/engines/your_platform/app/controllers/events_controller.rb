class EventsController < ApplicationController

  load_and_authorize_resource

  # GET /events
  # GET /events.json
  def index
    @events = Event.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @navable = @event
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])
    @event.name ||= I18n.t(:enter_name_of_event_here)
    @event.start_at ||= Time.zone.now.change(hour: 20, min: 15)
    
    respond_to do |format|
      if @event.save
        @group = Group.find(params[:group_id])
        @event.parent_groups << @group
        @event.contact_people << current_user
        @event[:path] = event_path(@event)
        
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
            partial: 'groups/member_avatars.html.haml', 
            layout: false,
            formats: [:json, :html],
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
    
    if params['recipient'] == 'me'
      recipients = [current_user]
      EventMailer.invitation_email(@text, recipients, @event, current_user).deliver
      
    elsif params['recipient'].kind_of? Integer
      group = Group.find params['recipient']
    end
    
    respond_to do |format|
      format.html { redirect_to event_url(@event) }
      format.json { head :no_content }
    end
  end
  
end
