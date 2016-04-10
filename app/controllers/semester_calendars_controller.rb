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

  def show
    @group = Group.find(params[:group_id] || raise('no group_id given'))
    authorize! :read, @group
    authorize! :index_events, @group

    @semester_calendar = @group.semester_calendar

    set_current_navable @group
    set_current_title "#{@group.title}: #{t(:semester_calendar)}"
  end

  def edit
    @group = Group.find(params[:group_id] || raise('no group_id given'))
    authorize! :read, @group
    authorize! :index_events, @group
    authorize! :create_event, @group

    @semester_calendar = @group.semester_calendar

    set_current_navable @group
    set_current_title "#{@group.title}: #{t(:semester_calendar)}"
  end

  def update
    @group = Group.find(params[:group_id] || raise('no group_id given'))
    authorize! :read, @group
    authorize! :index_events, @group
    authorize! :create_event, @group

    @semester_calendar = @group.semester_calendar
    @semester_calendar.update_attributes(params[:semester_calendar])

    redirect_to group_semester_calendar_path(@group)
  end

end