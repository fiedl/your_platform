class WorkflowsController < WorkflowKit::WorkflowsController
  
  # Exclude `execute` from standard `cancan` authorization,
  # since the needed authorization is checked by the method below.
  #
  skip_authorization_check :only => [:execute]

  # This override of the original execute method checks for the authorization
  # and then passes to the original method.
  #
  # If this override wouldn't be here, access would be denied on a global scale,
  # except for global admins.
  #
  def execute
    authorize! :execute, Workflow.find(params[:id])
    authorize! :manage, User.find(params[:user_id]) if params[:user_id]
    super
  end
end