class Api::V1::OfficesController < Api::V1::BaseController

  expose :office, -> { OfficerGroup.find params[:id] }
  expose :new_officers, -> { User.where(id: params[:officer_ids]) if params[:officer_ids].present? }

  def update
    authorize! :update, office
    authorize! :manage, office if new_officers

    office.update office_params if params[:office].present?
    assign_new_officers if new_officers

    render json: office, status: :ok
  end

  private

  def office_params
    params.require(:office).permit(:name)
  end

  def assign_new_officers
    office.members = new_officers
  end

end