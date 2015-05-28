class OfficerGroupsController < GroupsController
  
  def create
    # @scope (e.g. "My Page")
    #    |--- officers_parent
    #               |--------- @group (the OfficerGroup to be created)
    #
    (secure_parent_type.present? && params[:parent_id].present?) || raise('no officer group parent given.')
    @scope = secure_parent_type.constantize.find(params[:parent_id])
    
    authorize! :create_officer_group_for, @scope
    
    @group = @scope.officers_parent.child_groups.create(officer_group_params)
    @group.update_attribute :type, 'OfficerGroup'
    
    redirect_to :back, change: 'officers_table'
  end
  
  private
  
  def officer_group_params
    params.require(:officer_group).permit(:name)
  end
  
end