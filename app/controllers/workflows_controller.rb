class WorkflowsController < ApplicationController

  # Exclude `execute` from standard `cancan` authorization,
  # since the needed authorization is checked by the method below.
  #
  load_and_authorize_resource if respond_to? :load_and_authorize_resource
  skip_authorization_check :only => [:execute]


  # PUT /workflows/1/execute
  def execute
    authorize! :execute, Workflow.find(params[:id])
    authorize! :change_status, User.find(params[:user_id]) if params[:user_id]

    @workflow.execute( params )

    flash[ :notice ] = "#{I18n.t(:executed_workflow)}: #{@workflow.name}"
    redirect_to :back
  end


  # GET /workflows
  # GET /workflows.json
  def index
    @group = Group.find params[:group_id] if params[:group_id]
    if @group
      @workflows = @group.child_workflows

      authorize! :read, @group
      authorize! :read, @workflows
      set_current_navable @group
    else
      @workflows ||= Workflow.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workflows }
    end
  end

  # GET /workflows/1
  # GET /workflows/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @workflow }
    end
  end

  # GET /workflows/new
  # GET /workflows/new.json
  def new
    @workflow = Workflow.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @workflow }
    end
  end

  # GET /workflows/1/edit
  def edit
  end

  # POST /workflows
  # POST /workflows.json
  def create
    @workflow = Workflow.new(workflow_params)

    respond_to do |format|
      if @workflow.save
        format.html { redirect_to @workflow, notice: 'Workflow was successfully created.' }
        format.json { render json: @workflow, status: :created, location: @workflow }
      else
        format.html { render action: "new" }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /workflows/1
  # PUT /workflows/1.json
  def update
    respond_to do |format|
      if @workflow.update_attributes(workflow_params)
        format.html { redirect_to @workflow, notice: 'Workflow was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workflows/1
  # DELETE /workflows/1.json
  def destroy
    @workflow.destroy

    respond_to do |format|
      format.html { redirect_to workflows_url }
      format.json { head :no_content }
    end
  end

  private

  def workflow_params
    params.require(:workflow).permit(:description, :name, :parameters)
  end

end