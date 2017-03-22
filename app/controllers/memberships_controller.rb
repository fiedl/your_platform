class MembershipsController < ApplicationController

  authorize_resource

  expose :user
  expose :group
  expose :membership, -> {
    DagLink.find(params[:id]) || Membership.find_by_user_and_group(user, group).with_past
  }
  expose :memberships, -> {
    if user
      user.memberships.with_past
    elsif group
      group.memberships.with_past
    end
  }

  respond_to :json, :html

  def index
    if user
      authorize! :manage, user
      @object = user
    elsif group
      authorize! :manage, group
      @object = group
    end

    set_current_navable @object
    set_current_title "#{t(:memberships)}: #{@object.title}"
    set_current_activity :is_managing_member_lists, @object
  end

  def create
    if membership_params[:user_title].present?
      @user_id = User.find_by_title(membership_params[:user_title]).id
      @group = Group.find membership_params[:group_id]
      membership = true
      begin
        membership = Membership.create(membership_params.merge({user_id: @user_id}))
        membership.valid_from = Date.new(membership_params["valid_from(1i)"].to_i,
                                                     membership_params["valid_from(2i)"].to_i,
                                                     membership_params["valid_from(3i)"].to_i)
        membership.valid_from_will_change!
        membership.save!
        redirect_to group_members_path(membership.group), change: 'members'
      rescue => error
        redirect_to group_members_path(@group), change: 'members', alert: "#{t(:adding_member_did_not_work)} #{error.message}"
      end
    else
      head :no_content
    end
  end

  def show
  end

  def update
    if membership.update_attributes!( membership_params )
      respond_to do |format|
        format.json do
          #head :ok
          #respond_with_bip membership
          respond_with membership
        end
      end
    end
  end

  def destroy
    if membership
      membership.destroy
      head :no_content
    end
  end

  private

  def membership_params
    params[:membership] ||= params[:memberships_status]
    params.require(:membership).permit(*permitted_fields)
  end

  def unrestricted_fields
    [:valid_to, :valid_from, :user_title, :user_id, :group_id, :id,
    :valid_from_localized_date, :valid_to_localized_date]
  end

  def permitted_fields
    if can? :manage, membership
      unrestricted_fields + [:needs_review, :ancestor_id, :ancestor_type, :descendant_id, :descendant_type]
    elsif can? :update, membership
      unrestricted_fields
    end
  end


end
