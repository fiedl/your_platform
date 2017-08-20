class OfficerGroupsController < GroupsController

  def create
    # @scope (e.g. "My Page")
    #    |--- officers_parent
    #               |--------- @group (the OfficerGroup to be created)
    #
    (secure_parent_type.present? && params[:parent_id].present?) || raise(ActionController::ParameterMissing, 'no officer group parent given.')
    @scope = secure_parent_type.constantize.find(params[:parent_id])

    authorize! :create_officer_group_for, @scope

    @group = @scope.officers_parent.child_groups.create(officer_group_params)
    @group.update_attribute :type, 'OfficerGroup'

    redirect_back(fallback_location: group_members_path(group_id: @group))
  end

  def update
    @group = Group.find params[:id]
    authorize! :update, @group

    @group.update_attributes! officer_group_params

    respond_to do |format|
      format.json { respond_with_bip @group.reload }
    end
  end


  private

  def officer_group_params
    params.require(:officer_group).permit(:name, :direct_members_titles_string)
  end

end