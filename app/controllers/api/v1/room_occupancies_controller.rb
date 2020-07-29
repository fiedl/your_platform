class Api::V1::RoomOccupanciesController < Api::V1::BaseController

  expose :room, -> { Groups::Room.find params[:room_id] }
  expose :existing_user, -> { User.find params[:existing_user][:id] }
  expose :valid_from, -> { params[:valid_from].to_date }

  api :POST, '/api/v1/room_occupancies', "Set a new occupant for a room."

  def create
    authorize! :update, room

    terminate_existing_occupancies

    new_occupancy = nil if params[:occupancy_type] == 'empty'
    new_occupancy = create_from_existing_user if params[:occupancy_type] == 'existing_user'
    new_occupancy = create_from_new_user if params[:occupancy_type] == 'new_user'

    current_occupancy = room.memberships.where.not(id: new_occupancy.id).first
    new_occupancy.update valid_to: current_occupancy.valid_from if current_occupancy && (new_occupancy.valid_from < current_occupancy.valid_from)

    render json: new_occupancy, status: :ok
  end

  private

  def terminate_existing_occupancies
    room.memberships.where('valid_from < ?', valid_from).update_all valid_to: valid_from
  end

  def create_from_existing_user
    room.assign_user existing_user, at: valid_from
  end

  def create_from_new_user
    raise 'Kein Auftrag zur Datenverarbeitung erteilt.' unless params[:privacy].present?
    new_user = User.create first_name: params[:first_name], last_name: params[:last_name]
    new_user.date_of_birth = params[:date_of_birth].to_date
    new_user.mobile = params[:phone]
    new_user.email = params[:email]
    new_user.study_address = params[:study_address]
    new_user.home_address = params[:home_address]
    new_user.profile_fields.create(
      type: "ProfileFields::Study", label: params[:study],
      from: params[:study_from], university: params[:university], subject: params[:subject]
    )
    new_user.profile_fields.create(
      type: "ProfileFields::BankAccount", label: "Konto für Mieteinzug",
      account_holder: params[:account_holder], iban: params[:account_iban], bic: params[:account_bic]
    )
    new_user.save

    room.assign_user new_user, at: valid_from
  end

end