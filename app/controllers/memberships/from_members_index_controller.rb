class Memberships::FromMembersIndexController < ApplicationController

  expose :group
  expose :user, -> { User.find_by_title membership_params[:user_title] }

  # POST groups/123/members/memberships
  def create
    authorize! :add_member_to, group
    raise 'No user title given' unless membership_params[:user_title].present?
    raise 'User not found' unless user

    if (membership = group.assign_user(user, at: processed_membership_params[:valid_from])) && membership.errors.none?
      Rails.cache.renew { group.member_table_rows }

      render json: {
        membership: membership.as_json,
        group_members_table_html: render_partial('groups/member_list', group: group, member_table_rows: group.member_table_rows)
      }
    else
      raise membership.errors
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