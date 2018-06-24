class MembersDashboardController < ApplicationController

  def index
    authorize! :index, :members

    if params[:group_id]
      redirect_to group_members_path(group_id: params[:group_id])
    else
      # TODO: Render dashboard
    end
  end

end