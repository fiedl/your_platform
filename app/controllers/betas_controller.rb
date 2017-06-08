class BetasController < ApplicationController
  load_and_authorize_resource

  # GET /betas
  def index
    set_current_title t :betas
    set_current_breadcrumbs [
      {title: Page.root.title, path: public_root_path},
      {title: Page.intranet_root.title, path: root_path},
      {title: current_title}
    ]
  end

  # GET /betas/1
  def show
    set_current_title "Beta: #{@beta.title}"
    set_current_breadcrumbs [
      {title: Page.root.title, path: public_root_path},
      {title: Page.intranet_root.title, path: root_path},
      {title: t(:betas), path: betas_path},
      {title: current_title}
    ]
  end

  # GET /betas/new
  def new
  end

  # GET /betas/1/edit
  def edit
  end

  # POST /betas
  def create
    if @beta.save
      @beta.invitations.create invitee_id: current_user.id

      redirect_to @beta, notice: 'Beta was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /betas/1
  def update
    if @beta.update(beta_params)
      redirect_to @beta, notice: 'Beta was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /betas/1
  def destroy
    @beta.destroy
    redirect_to betas_url, notice: 'Beta was successfully destroyed.'
  end

  private

  # Only allow a trusted parameter "white list" through.
  def beta_params
    params.require(:beta).permit(:title, :max_invitations_per_inviter, :key, :description)
  end
end
