class Api::V1::MembersController < Api::V1::BaseController

  expose :group
  expose :user, -> { User.find(params[:user_id]) }
  expose :joined_at, -> { params[:joined_at].try(:to_date) }

  api :POST, '/api/v1/groups/ID/members', "Add a user as member to a group"
  param :id, :number, "Group id of the requested group"

  def create
    authorize! :add_member, group

    membership = group.assign_user user, at: joined_at

    render json: {
      group: group,
      user: user,
      membership: membership,
      member_table_rows: group.member_table_rows
    }, status: :ok
  end

end