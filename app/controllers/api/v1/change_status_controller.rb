class Api::V1::ChangeStatusController < Api::V1::BaseController

  expose :user, -> { User.find params[:user_id] if params[:user_id].present? }
  expose :corporation, -> { Corporation.find params[:corporation_id] if params[:corporation_id].present? }
  expose :status_group, -> { Group.find params[:status_id] if params[:status_id].present? }
  expose :valid_from, -> { params[:valid_from].to_date }

  def create
    authorize! :change_status, user
    raise 'no corporation given.' unless corporation
    raise 'no status_group given.' unless status_group
    raise 'status_group does not match corporation' unless corporation.descendant_group_ids.include? status_group.id

    terminate_previous_status_memberships
    new_membership = status_group.assign_user user, at: valid_from

    render json: new_membership, status: :ok
  end

  def terminate_previous_status_memberships
    user
      .links_as_child.where(ancestor_type: 'Group', ancestor_id: (user.group_ids & corporation.status_group_tree_ids))
      .each { |membership| membership.invalidate at: valid_from }
  end

end