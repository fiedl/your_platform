class UserGroupMembershipsController < ApplicationController

  before_filter :find_membership
  authorize_resource

  respond_to :json
  
  def create
    if params[:user_group_membership][:user_title].present?
      @user_id = User.find_by_title(params[:user_group_membership][:user_title]).id
      @user_group_membership = UserGroupMembership.create(params[:user_group_membership].merge({user_id: @user_id}))
    else
      head :no_content
    end
  end

  def show
    # update  # 2013-02-03 SF: This seems wrong, does it not?
  end

  def update
    attributes = params[ :user_group_membership ]
    attributes ||= params[ :status_group_membership ]

    if @user_group_membership.update_attributes!( attributes )
      respond_to do |format|
        format.json do
          #head :ok
          #respond_with_bip @user_group_membership
          respond_with @user_group_membership
        end
      end
    end
  end

  def destroy
    if @user_group_membership
      @user_group_membership.destroy
      redirect_to :back
    end
  end

  private

  def find_membership
    if params[ :id ].present?
      @user_group_membership = UserGroupMembership.with_invalid.find( params[ :id ] )
    else
      user = User.find params[ :user_id ] if params[ :user_id ]
      group = Group.find params[ :group_id ] if params[ :group_id ]
      if user && group
        @user_group_membership = UserGroupMembership.with_invalid.find_by_user_and_group user, group
      end
    end
  end
  
end
