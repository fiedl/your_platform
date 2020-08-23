class EventsController < ApplicationController

  expose :user, -> { User.find params[:user_id] if params[:user_id].present? }
  expose :group, -> {
    (Group.find params[:group_id] if params[:group_id].present?) ||
    (event.group || event.parent_groups.first if event)
  }
  expose :parent, -> { user || group }
  expose :category, -> { params[:category] }
  expose :semester_calendars, -> { (user.corporations.map(&:semester_calendar) if user) || ([group.semester_calendar] if group && group.semester_calendar) || [] }
  expose :events, -> {
    events = parent.events if parent
    events ||= Event.all
    events = events.commers if category == "Stiftungsfeste"
    events = events.bundesconvent if category == "Bundesconvente"
    events = Group.where(name: "Wingolfsseminare").first.events if category == "Wingolfsseminare"
    events = Group.alle_wingolfiten.events.wartburgfest.where(publish_on_global_website: true) if category == "Wartburgfeste"
    events = events.where(publish_on_global_website: true) if params[:published_on_global_website].to_b
    events = events.reorder(start_at: :desc)
    events = events.limit(100) unless params[:all].to_b
    events
  }

  def index
    authorize! :index, Event

    respond_to do |format|
      format.html do
        if user
          authorize! :index_events, user
          set_current_navable user
          if user == current_user
            set_current_title "Meine Veranstaltungen"
          else
            set_current_title "Veranstaltungen von #{user.title}"
          end
        end

        if category.present?
          set_current_title category
        elsif params[:published_on_global_website].to_b
          set_current_title "Veranstaltungen aus dem Bund"
        end

        if group
          set_current_title "Veranstaltungen"
          set_current_navable group
        end

        set_current_tab :events
      end
      format.ics {
        # TODO: The router should send this request to a dedicated controller.
        # But I haven't found a way to do so, yet.
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
        @events = Event.where(id: @events.select { |event| can? :read, event }.pluck(:id)).order('events.start_at, events.created_at')

        # Add the Cross-origin resource sharing header for public requests.
        response.headers['Access-Control-Allow-Origin'] = '*' if @public

        send_data @events.to_ics, filename: "#{@group.try(:name)} #{Time.zone.now}".parameterize + ".ics"
      }
    end
  end

  expose :event, -> { Event.find(params[:id]) if params[:id] }
  expose :corporation, -> { group.try(:corporation) }

  expose :posts, -> { event.child_posts.published.order(published_at: :desc).accessible_by(current_ability) }
  expose :drafted_post, -> { current_user.drafted_posts.where(sent_via: post_draft_via_key).last }
  expose :post_draft_via_key, -> { "event-#{event.id}" }

  def show
    authorize! :read, event
    set_current_navable event

    respond_to do |format|
      format.html do
        set_current_title event.name
        set_current_tab :events
      end
      format.ics { render plain: event.to_ics }
    end
  end

  def update
    authorize! :update, event

    event.update_attributes!(event_params)
    render json: event, status: :ok
  end

  private

  def event_params
    params.require(:event).permit(:name, :description, :start_at, :end_at, :location, :publish_on_local_website, :publish_on_global_website, :group_id, :contact_person_id, :avatar, :avatar_background)
  end

end
