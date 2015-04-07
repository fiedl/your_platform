class UserGroupMembershipsController < ApplicationController

  before_action :find_membership
  authorize_resource

  respond_to :json, :html
  
  def index
    authorize! :manage, @user
    
    @user = User.find(params[:user_id])
    @memberships = UserGroupMembership.now_and_in_the_past.find_all_by_user(@user)
    @navable = @user
  end
  
  def create
    if membership_params[:user_title].present?
      @user_id = User.find_by_title(membership_params[:user_title]).id
      @user_group_membership = UserGroupMembership.create(membership_params.merge({user_id: @user_id}))
    else
      head :no_content
    end
  end

  def show
    # update  # 2013-02-03 SF: This seems wrong, does it not?
  end

  def update
    if @user_group_membership.update_attributes!( membership_params )
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
      head :no_content
    end
  end

  private

  def membership_params
    unrestricted_params = [:valid_to, :valid_from, :user_title, :user_id, :group_id, :id,
                    :valid_from_localized_date, :valid_to_localized_date]
    unfiltered_params = params.require(:user_group_membership) || params.require(:status_group_membership)
    if can? :manage, @user_group_membership
      restricted_params = unrestricted_params + [:needs_review, :ancestor_id, :ancestor_type, :descendant_id,
                                                     :descendant_type]
      unfiltered_params.permit(*restricted_params)
    elsif can? :update, @user_group_membership
      unfiltered_params.permit(*unrestricted_params)
    end
  end

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
