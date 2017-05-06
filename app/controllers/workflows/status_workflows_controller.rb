class Workflows::StatusWorkflowsController < ApplicationController

  # PUT /workflows/1/execute
  def execute
    @workflow = Workflow.find params[:id]
    @user = User.find params[:user_id]

    authorize! :execute, @workflow
    authorize! :change_status, @user

    @workflow.execute(params)

    Rails.cache.renew do
      @user.status
      @user.workflows_by_corporation
    end

    activity = log_public_activity_for_user
    Notification.create_from_status_workflow(@workflow, @user, current_user)

    respond_to do |format|
      # Next, the corporate vita section is replaced by
      # app/views/workflows/status_workflows/execute.js
      #
      format.js
    end
  end

  private

  # The PublicActivity::Activity is logged by the application controller. But it is not
  # very helpful to know that workflow 1234 has been executed. Therefore,
  # we log additional information here.
  #
  def log_public_activity_for_user
    PublicActivity::Activity.create(
      trackable: @user,
      key: "execute workflow #{@workflow.name}",
      owner: current_user,
      parameters: {
        workflow_id: @workflow.id,
        new_status: @user.status_string
      }
    )
  end


end