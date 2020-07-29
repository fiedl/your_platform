class Api::V1::RoomsController < Api::V1::BaseController

  expose :corporation, -> { Corporation.find(params[:corporation_id]) }
  expose :rooms, -> { corporation.rooms.order(:name) }
  expose :room, -> { Groups::Room.find(params[:id]) }

  api :GET, '/api/v1/corporations/ID/rooms', "Returns the rooms that belong to the corporation."

  def index
    authorize! :index, Groups::Room

    render json: rooms
  end

  api :POST, '/api/v1/corporations/ID/rooms'

  def create
    authorize! :update_accommodations, corporation

    new_room = corporation.create_room room_params
    render json: new_room, status: :ok
  end

  def update
    authorize! :update_accommodations, room.corporation

    room.update! room_params
    render json: room, status: :ok
  end

  def destroy
    authorize! :update_accommodations, room.corporation
    raise "Cannot remove room if it has current or past occupants" if room.memberships.with_past.any?

    room.destroy!
    render json: {}, status: :ok
  end

  private

  def room_params
    params.require(:room).permit(:name, :rent, :occupant_id, :occupant_since)
  end

end