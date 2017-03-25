
class StatusMembershipsController < ApplicationController

  before_action :find_membership
  load_and_authorize_resource

  respond_to :json

  def update
    attributes = params[:status_membership]
    if @status_membership.update_attributes(attributes)
      respond_with @status_membership
    else
      raise "updating attributes of membership has failed: " + @status_membership.errors.full_messages.first
    end
  end

  def destroy
    @status_membership.destroy if @status_membership
  end

  private

  def status_membership_params
    params.require(:status_membership).permit(:valid_from, :valid_to, :valid_from_localized_date, :valid_to_localized_date, :needs_review)
  end

  def find_membership
    @status_membership = Memberships::Status.with_invalid.find(params[:id]) if params[:id].present?
  end

end
