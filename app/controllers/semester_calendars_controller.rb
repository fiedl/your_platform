# This shows corporation events grouped by semester.
#
#       1 Jan |
#       2 Feb |
#       3 Mrz -
#       4 Apr |
#       5 Mai |
#       6 Jun | Sommersemester
#       7 Jul |
#       8 Aug |
#       9 Sep -
#      10 Okt |
#      11 Nov | Wintersemester
#      12 Dez |
#
class SemesterCalendarsController < ApplicationController
  after_action :log_public_activity_for_semester_calendar, only: [:update]
  help_topic :semester_calendars

  include CurrentTerm

  expose :semester_calendar, -> {
    if params[:id] || params[:semester_calendar_id]
      SemesterCalendar.find (params[:id] || params[:semester_calendar_id])
    elsif term && corporation
      SemesterCalendar.by_corporation_and_term corporation, term
    elsif corporation
      SemesterCalendar.by_corporation_and_term corporation, Term.current.first
    end
  }

  expose :termable, -> { semester_calendar }


  def show
    authorize! :read, semester_calendar

    set_current_navable group
    set_current_title "#{group.title}: #{t(:semester_calendar)}"
    set_current_tab :events
    set_current_activity :is_looking_at_semester_calendar, semester_calendar
    set_current_access :signed_in
    set_current_access_text :all_signed_in_users_can_read_this_content
  end

  def edit
    authorize! :read, group
    authorize! :create_event, group
    authorize! :update, semester_calendar

    set_current_navable group
    set_current_title "#{group.title}: #{t(:semester_calendar)}"
    set_current_activity :is_editing_a_semester_calendar, semester_calendar
    set_current_access :signed_in
    set_current_access_text :only_officers_can_edit_this_content
  end

  def update
    authorize! :read, group
    authorize! :create_event, group
    authorize! :update, semester_calendar

    semester_calendar.update_attributes(semester_calendar_params)
    render json: semester_calendar.as_json.merge({
      attachment: semester_calendar.attachments.last
    }), status: :ok
  end

  def index
    if group
      authorize! :read, group
      @semester_calendars = group.semester_calendars.order(:year, 'term desc')

      set_current_navable group
      set_current_title "#{I18n.t(:semester_calendars)} #{group.title}"
      set_current_tab :events
    else
      authorize! :index, SemesterCalendar

      @semester_calendars = SemesterCalendar.where(term_id: term.id).includes(:group).order('groups.name asc')

      if current_user && current_user.corporations_the_user_is_officer_in.count == 1
        @corporation_of_the_current_officer = current_user.corporations_the_user_is_officer_in.first
      end

      @public_events = Event.where(publish_on_global_website: true, start_at: term.time_range)

      set_current_title t(:semester_calendars)
      set_current_breadcrumbs [
        {title: current_title}
      ]
      set_current_tab :events
      set_current_activity :is_looking_at_semester_calendars
      set_current_access :signed_in
      set_current_access_text :all_signed_in_users_can_read_this_content
    end
  end

  def destroy
    authorize! :destroy, @semester_calendar

    PublicActivity::Activity.create!(
      trackable: @group,
      key: "Destroy semester calendar #{@semester_calendar.title(locale: current_user.locale)}",
      owner: current_user,
      parameters: params.to_unsafe_hash.except('authenticity_token')
    )

    @semester_calendar.destroy
  end

  private

  def semester_calendar_params
    params.require(:semester_calendar).permit(:year, :term, :attachment, events_attributes: [:id, :name, :location, :start_at, :localized_start_at, :aktive, :philister, :publish_on_local_website, :publish_on_global_website, :contact_person_id, :_destroy])
  end


  def log_public_activity_for_semester_calendar
    semester_calendar.events.each do |event|
      PublicActivity::Activity.create(
        trackable: event,
        key: "edit event via semester calendar",
        owner: current_user,
        parameters: {
          event_name: event.title,
          group_name: event.group.try(:name)
        }
      )
    end
  end

end