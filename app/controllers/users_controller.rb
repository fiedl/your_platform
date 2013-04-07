# -*- coding: utf-8 -*-
class UsersController < ApplicationController

  respond_to :html, :json, :js
  before_filter :find_user, only: [:show, :update, :forgot_password]
  before_filter :authenticate_user_account!

  def index
    begin
      redirect_to Group.everyone
    rescue
      raise "No basic groups are present, yet. Try `rake bootstrap:all`."
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
                  #format.json { render json: @profile.sections }  # TODO
    end
  end

  def create_profile_field()
    @user = User.find_by_id(params[:profileable_id])
    type = params[:type]
    ProfileField #require
    @profile_field = type.constantize.create
    @profile_field.profileable_id = @user.id
    @profile_field.profileable_type = "User"
    @profile_field.save

    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def new
    @title = t(:create_user)
    @user = User.new
    @user.alias = params[:alias]
    @group = Group.find(params[:group_id]) if params[:group_id]
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to @user
    else
      @title = t :create_user
      @user.valid?
      render :action => "new"
    end
  end

  def update
    @user.update_attributes(params[:user])
    respond_with @user
  end

  def autocomplete_title
    query = ""
    query ||= params[:term] if params[ :term ]
    query ||= params[ :query ] if params[ :query ]
    @users = User.all.select { |user| user.title.downcase.include? query.downcase }
    #render json: json_for_autocomplete(@users, :title)
    render json: @users.to_json( :methods => [ :title ] )
  end

  def forgot_password
    @user.account.send_new_password
    flash[:notice] = I18n.t(:new_password_has_been_sent_to, user_name: @user.title)
    redirect_to :back
  end

  private

  def find_user
    @user = User.find(params[:id]) if params[:id].present?
    @user ||= User.find_by_alias(params[:alias]) if params[:alias].present?
    @user ||= User.new
    @title = @user.title
    @navable = @user
  end

end
