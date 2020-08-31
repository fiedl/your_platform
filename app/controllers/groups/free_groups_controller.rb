class Groups::FreeGroupsController < ApplicationController

  def create
    authorize! :create, Groups::FreeGroup

    new_group = Groups::FreeGroup.create name: "Neue Gruppe", body: "Beschreibe doch kurz Deine neue Gruppe!"
    new_group.members << current_user

    founders = new_group.create_office name: "Gruppen-Manager"
    founders.members << current_user

    redirect_to group_posts_path(new_group)
  end

  expose :group, -> { Groups::FreeGroup.find params[:id] }

  def update
    authorize! :update, group

    group.update! group_params
    render json: {}, status: :ok
  end

  def destroy
    authorize! :destroy, group
    group.destroy!
    redirect_to user_groups_path(current_user)
  end

  private

  def group_params
    params.require(:groups_free_group).permit(:name, :body)
  end

end