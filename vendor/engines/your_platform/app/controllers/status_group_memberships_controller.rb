
class StatusGroupMembershipsController < ApplicationController

  before_filter :find_membership
  respond_to :json

  def update
    attributes = params[ :status_group_membership ]
    if @membership.update_attributes( attributes )
      respond_with @membership
    else
      raise "updating attributes of user_group_membership has failed: " + @membership.errors.full_messages.first
    end
  end

  def destroy
    @membership.destroy if @membership
  end

  private

  def find_membership
    @membership = StatusGroupMembership.with_deleted.find( params[ :id ] ) if params[ :id ]
  end
  
end
