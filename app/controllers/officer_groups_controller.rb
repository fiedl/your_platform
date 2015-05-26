class OfficerGroupsController < GroupsController
  
  def create
    (secure_parent_type.present? && params[:parent_id].present?) || raise('no officer group parent given.')
    @parent = secure_parent_type.constantize.find(params[:parent_id])
    
    authorize! :create_officers_group_for, @parent
    
    @group = @parent.child_groups.create(group_params.except(:parent_id, :parent_type))
    @group.update_attribute :type, 'OfficerGroup'
    
    redirect_to :back, change: 'officers_table'
  end
  
end