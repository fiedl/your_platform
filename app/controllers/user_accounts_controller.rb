class UserAccountsController < ApplicationController

  load_and_authorize_resource
  skip_authorize_resource only: [:create]
  layout               false

  after_action :log_public_activity_for_user, only: [:create, :destroy]

  def show
    @user_account = UserAccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_account }
    end
  end

  def new
    @user_account = UserAccount.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_account }
    end
  end

  def edit
    @user_account = UserAccount.find(params[:id])
  end

  def create
    @user = User.find_by_id(params[:user_id])
    @user_account = @user.build_account
    authorize! :create_account_for, @user

    respond_to do |format|
      if @user_account.save

        @user.send_welcome_email

        format.html { redirect_to :back, notice: t(:user_account_created) }
        format.json { render json: @user_account, status: :created, location: @user_account }
      else
        format.html { redirect_to :back, flash: {error: @user_account.errors.full_messages.join(", ")} }
        format.json { render json: @user_account.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if params[:id]
      @user_account = UserAccount.find(params[:id])
      @user = @user_account.user
    elsif params[:user_id]
      @user = User.find params[:user_id]
      @user_account = @user.account
    else
      raise ActionController::ParameterMissing, 'neither [account] :id nor :user_id given.'
    end

    if @user_account.destroy
      respond_to do |format|
        format.html { redirect_to user_path(@user), notice: t(:user_account_deleted)  }
        format.json { head :no_content }
      end
    end
  end

  private

  # The PublicActivity::Activity is logged by the application controller. But we need
  # to log additional information here.
  #
  def log_public_activity_for_user
    PublicActivity::Activity.create(
      trackable: @user,
      key: "#{action_name} user account",
      owner: current_user
    )
  end


end
