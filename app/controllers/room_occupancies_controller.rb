class RoomOccupanciesController < ApplicationController

  expose :group
  expose :room, -> { group if group.kind_of? Groups::Room }
  expose :scope, -> { room.parent_groups.try(:first) }

  def new
    authorize! :manage, room

    set_current_navable scope
  end

end