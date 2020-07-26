class RoomOccupanciesController < ApplicationController

  expose :group
  expose :room, -> { group if group.kind_of? Groups::Room }
  expose :scope, -> { room.parent_groups.try(:first) }
  expose :corporation, -> { room.corporation }
  expose :redirect_to_url, -> { corporation_accommodations_path(corporation_id: corporation.id) }

  def index
    authorize! :manage, room

    set_current_title room.title
    set_current_tab :contacts
  end

  def new
    authorize! :manage, room

    set_current_title room.title
    set_current_navable scope
    set_current_tab :contacts
  end

  def create
    authorize! :manage, room

    date = params[:occupancy_since]

    room.memberships.at_time(date).each do |membership|
      membership.invalidate at: date
    end

    case params[:occupancy_type]
    when 'empty'
      redirect_to group_room_occupants_path(group_id: room.parent.id)
    when 'existing_user'
      room.assign_user User.find_by_title(params[:existing_user_title]), at: date
      redirect_to group_room_occupants_path(group_id: room.parent.id)
    when 'new_user'
      redirect_to new_user_path(group_id: room.id, group_member_since: date)
    end
  end

end