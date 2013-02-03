
class UserGroupMembershipsController < ApplicationController

  before_filter :find_membership
#  respond_to :html, :json
  respond_to :json

  def show
    # update  # 2013-02-03 SF: This seems wrong, does it not?
  end

  def update
    if @membership.update_attributes( params[ :user_group_membership ] )
      respond_to do |format|
        format.json do
          #head :ok
          respond_with_bip @membership
        end
      end
    else
      raise "updating attributes of user_group_membership has failed: " + @membership.errors.full_messages.first
    end
  end

  def destroy
    if @membership
      @membership.destroy
      redirect_to :back
    end
  end

  private

  def find_membership
    user = User.find params[ :user_id ]
    group = Group.find params[ :group_id ]
    if user && group
      @membership = UserGroupMembership.find_by_user_and_group user, group
    end
  end
  
end
