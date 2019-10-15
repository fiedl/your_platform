class Groups::RoomsController < GroupsController

  def update
    super
  end

  def group_params
    params[:group] ||= params[:groups_room]
    params[:groups_room] ||= params[:group]

    super
  end

  def permitted_group_attributes
    if can? :manage, @group
      super + [:rent, :occupant_title]
    else
      super
    end
  end

end