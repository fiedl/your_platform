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
  before_action :load_resource, except: [:index, :new]
  after_action :log_public_activity_for_semester_calendar, only: [:update]

  def show
    authorize! :read, @group
    authorize! :read, @semester_calendar

    set_current_navable @group
    set_current_title "#{@group.title}: #{t(:semester_calendar)}"
    set_current_tab :events
    set_current_activity :is_looking_at_semester_calendar, @semester_calendar
    set_current_access :signed_in
    set_current_access_text :all_signed_in_users_can_read_this_content
  end

  def show_current
    authorize! :read, @group

    if @semester_calendar = @group.semester_calendars.current.last
      redirect_to @semester_calendar
    else
      redirect_to group_semester_calendars_path(@group)
    end
  end

  def new
    authorize! :create, SemesterCalendar

    @new_semester_calendar = SemesterCalendar.new(year: Time.zone.now.year, term: SemesterCalendar.current_term)
    @corporations = Corporation.all.select do |corporation|
      can? :create_semester_calendar_for, corporation
    end

    set_current_title t(:new_semester_calendar)
    set_current_breadcrumbs [
      {title: t(:semester_calendars), path: semester_calendars_path},
      {title: current_title}
    ]
  end

  def edit
    authorize! :read, @group
    authorize! :create_event, @group
    authorize! :update, @semester_calendar

    set_current_navable @group
    set_current_title "#{@group.title}: #{t(:semester_calendar)}"
    set_current_activity :is_editing_a_semester_calendar, @semester_calendar
    set_current_access :signed_in
    set_current_access_text :only_officers_can_edit_this_content
  end

  def update
    authorize! :read, @group
    authorize! :create_event, @group
    authorize! :update, @semester_calendar

    @semester_calendar.update_attributes(semester_calendar_params) if semester_calendar_params
    redirect_to group_semester_calendar_path(group_id: @group.id, id: @semester_calendar.id)
  end

  def update_term_and_year
    authorize! :read, @group
    authorize! :create_event, @group
    authorize! :update, @semester_calendar

    @semester_calendar.update_attributes(semester_calendar_params)
    @semester_calendar.reload

    # Then, the javascript in app/views/semester_calendars/update_term_and_year.js
    # is executed.
  end

  def index
    if params[:group_id]
      @group = Group.find(params[:group_id])

      authorize! :read, @group
      @semester_calendars = @group.semester_calendars.order(:year, 'term desc')

      set_current_navable @group
      set_current_title "#{I18n.t(:semester_calendars)} #{@group.title}"
      set_current_tab :events
    else
      authorize! :index, SemesterCalendar

      params[:year] ||= params[:semester_calendar].try(:[], :year) || Time.zone.now.year
      params[:term] ||= params[:semester_calendar].try(:[], :term) || SemesterCalendar.current_term

      @semester_calendars = SemesterCalendar.all
      @semester_calendars = @semester_calendars.where(year: params[:year]) if params[:year]
      @semester_calendars = @semester_calendars.where(term: SemesterCalendar.terms[params[:term]]) if params[:term]
      @semester_calendars = @semester_calendars.includes(:group).order('groups.name asc')

      if current_user.corporations_the_user_is_officer_in.count == 1
        @corporation_of_the_current_officer = current_user.corporations_the_user_is_officer_in.first
      end

      @public_events = SemesterCalendar.all_public_events_for(year: params[:year], term: params[:term]).order(:start_at)

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

  def create
    authorize! :create_semester_calendar_for, @group

    attributes = semester_calendar_params
    attributes[:year] ||= Time.zone.now.year
    attributes[:term] ||= SemesterCalendar.current_term

    @semester_calendar = @group.semester_calendars.new(attributes)
    @semester_calendar.save!
    redirect_to edit_semester_calendar_path(@semester_calendar)
  end

  def destroy
    authorize! :destroy, @semester_calendar

    PublicActivity::Activity.create!(
      trackable: @group,
      key: "Destroy semester calendar #{@semester_calendar.title(locale: current_user.locale)}",
      owner: current_user,
      parameters: params.except('authenticity_token')
    )

    @semester_calendar.destroy
  end

  private

  def load_resource
    params[:group_id] ||= params[:semester_calendar].try(:[], :group_id)
    if params[:group_id]
      @group = Group.find params[:group_id]
      @semester_calendar = @group.semester_calendars.find(params[:id]) if params[:id]
      @semester_calendar ||= @group.semester_calendars.last
    else
      @semester_calendar = SemesterCalendar.find params[:id]
      @group = @semester_calendar.group
    end
  end

  def semester_calendar_params
    if (@semester_calendar and can?(:update, @semester_calendar)) or (@group and can?(:create_semester_calendar_for, @group))
      if params[:semester_calendar]
        params.require(:semester_calendar).permit(:year, :term, events_attributes: [:id, :name, :location, :start_at, :localized_start_at, :aktive, :philister, :publish_on_local_website, :publish_on_global_website, :contact_person_id, :_destroy])
      else
        {}
      end
    end
  end


  def log_public_activity_for_semester_calendar
    @semester_calendar.events.each do |event|
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