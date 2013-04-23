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
    #@user_account = UserAccount.new(params[:user_account])

    respond_to do |format|
      if @user_account.save
        format.html { redirect_to :back, notice: 'User account was successfully created.' }
        format.json { render json: @user_account, status: :created, location: @user_account }
      else
        format.html { render action: "new" }
        format.json { render json: @user_account.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @user_account = UserAccount.find(params[:id])

    respond_to do |format|
      if @user_account.update_attributes(params[:user_account])
        format.html { redirect_to @user_account, notice: 'User account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_account.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user_account = UserAccount.find(params[:id])
    @user_account.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
end
