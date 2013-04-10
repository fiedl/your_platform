
class StatusGroupMembershipsController < ApplicationController

  before_filter :find_membership
  load_and_authorize_resource

  respond_to :json

  def update
    attributes = params[ :status_group_membership ]
    if @status_group_membership.update_attributes( attributes )
      respond_with @status_group_membership
    else
      raise "updating attributes of user_group_membership has failed: " + @status_group_membership.errors.full_messages.first
    end
  end

  def destroy
    @status_group_membership.destroy if @status_group_membership
  end

  private

  def find_membership
    @status_group_membership = StatusGroupMembership.with_deleted.find( params[ :id ] ) if params[ :id ].present?
  end
  
end
