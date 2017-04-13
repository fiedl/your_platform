class Memberships::FromMembersIndexController < ApplicationController

  expose :group
  expose :user, -> { User.find_by_title membership_params[:user_title] }

  # POST groups/123/members/memberships
  def create
    authorize! :manage_memberships_manually, group
    raise 'No user title given' unless membership_params[:user_title].present?

    if (membership = group.assign_user(user, at: processed_membership_params[:valid_from])) && membership.errors.none?
      redirect_to group_members_path(group)
    else
      redirect_to group_members_path(group), alert: "#{t(:adding_member_did_not_work)} #{membership.errors.messages.to_s}"
    end
  end

  private

  def membership_params
    params.require(:membership).permit(:user_title, "valid_from(1i)", "valid_from(2i)", "valid_from(3i)")
  end

  def processed_membership_params
    membership_params.merge({
      user_id: user.id,
      valid_from: Date.new(membership_params["valid_from(1i)"].to_i, membership_params["valid_from(2i)"].to_i, membership_params["valid_from(3i)"].to_i).to_datetime.change(hour: 2)
    }).except("valid_from(1i)", "valid_from(2i)", "valid_from(3i)", :user_title)
  end

  def log_activity
    unless read_only_mode?
      PublicActivity::Activity.create!(
        trackable: user,
        key: "create membership",
        owner: current_user,
        parameters: processed_membership_params.merge({group_id: group.id})
      )
      PublicActivity::Activity.create!(
        trackable: group,
        key: "create membership",
        owner: current_user,
        parameters: processed_membership_params
      )
    end
  end

end