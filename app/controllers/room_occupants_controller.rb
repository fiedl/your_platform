class RoomOccupantsController < ApplicationController

  expose :group
  expose :room_occupants, -> { group.members }
  expose :rooms, -> { group.descendant_groups.where(type: "Groups::Room") }

  def index
    authorize! :read, group

    set_current_navable group
  end

end