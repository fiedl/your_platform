
class UserGroupMembershipsController < ApplicationController

  before_filter :find_membership
  respond_to :html, :json

  def show
    update
  end

  def update
    if @membership.update_attributes( params[ :user_group_membership ] )
      respond_to do |format|
        format.json do
          #head :ok
          respond_with_bip @membership
        end
      end
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
