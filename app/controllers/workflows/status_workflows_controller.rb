class Workflows::StatusWorkflowsController < ApplicationController
  
  # PUT /workflows/1/execute
  def execute
    @workflow = Workflow.find params[:id]
    @user = User.find params[:user_id]

    authorize! :execute, @workflow
    authorize! :change_status, @user

    @workflow.execute(params)
    @user.renew_cache
    
    respond_to do |format|
      # Next, the corporate vita section is replaced by
      # app/views/workflows/status_workflows/execute.js
      #
      format.js
    end
  end
  
end