class UserAccountsController < ApplicationController

  load_and_authorize_resource
  layout               false

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

    respond_to do |format|
      if @user_account.save

        @user.send_welcome_email
        
        format.html { redirect_to :back, notice: t(:user_account_created) }
        format.json { render json: @user_account, status: :created, location: @user_account }
      else
        format.html { render action: "new" }
        format.json { render json: @user_account.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user_account = UserAccount.find(params[:id])
    @user_account.destroy

    respond_to do |format|
      format.html { redirect_to :back, notice: t(:user_account_deleted)  }
      format.json { head :no_content }
    end
  end
end
