class MembershipsController < ApplicationController

  before_action :find_membership
  authorize_resource

  respond_to :json, :html

  def index
    if params[:user_id]
      @object = @user = User.find(params[:user_id])
      authorize! :manage, @user

      @memberships = Membership.now_and_in_the_past.find_all_by_user(@user)
    elsif params[:group_id]
      @object = @group = Group.find(params[:group_id])
      authorize! :manage, @group

      @memberships = Membership.now_and_in_the_past.find_all_by_group(@group)
    end

    set_current_navable @object
    set_current_title "#{t(:memberships)}: #{@object.title}"
    set_current_activity :is_managing_member_lists, @object
  end

  def create
    if membership_params[:user_title].present?
      @user_id = User.find_by_title(membership_params[:user_title]).id
      @group = Group.find membership_params[:group_id]
      @membership = true
      begin
        @membership = Membership.create(membership_params.merge({user_id: @user_id}))
        @membership.valid_from = Date.new(membership_params["valid_from(1i)"].to_i,
                                                     membership_params["valid_from(2i)"].to_i,
                                                     membership_params["valid_from(3i)"].to_i)
        @membership.valid_from_will_change!
        @membership.save!
        redirect_to group_members_path(@membership.group), change: 'members'
      rescue => error
        redirect_to group_members_path(@group), change: 'members', alert: "#{t(:adding_member_did_not_work)} #{error.message}"
      end
    else
      head :no_content
    end
  end

  def show
    # update  # 2013-02-03 SF: This seems wrong, does it not?
  end

  def update
    if @membership.update_attributes!( membership_params )
      respond_to do |format|
        format.json do
          #head :ok
          #respond_with_bip @membership
          respond_with @membership
        end
      end
    end
  end

  def destroy
    if @membership
      @membership.destroy
      head :no_content
    end
  end

  private

  def membership_params
    unrestricted_params = [:valid_to, :valid_from, :user_title, :user_id, :group_id, :id,
                    :valid_from_localized_date, :valid_to_localized_date]
    unfiltered_params = params.require(:membership) || params.require(:status_membership)
    if can? :manage, @membership
      restricted_params = unrestricted_params + [:needs_review, :ancestor_id, :ancestor_type, :descendant_id,
                                                     :descendant_type]
      unfiltered_params.permit(*restricted_params)
    elsif can? :update, @membership
      unfiltered_params.permit(*unrestricted_params)
    end
  end

  def find_membership
    if params[ :id ].present?
      @membership = Membership.with_invalid.find( params[ :id ] )
    else
      user = User.find params[ :user_id ] if params[ :user_id ]
      group = Group.find params[ :group_id ] if params[ :group_id ]
      if user && group
        @membership = Membership.with_invalid.find_by_user_and_group user, group
      end
    end
  end

end
