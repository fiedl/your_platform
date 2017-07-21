# -*- coding: utf-8 -*-
class UsersController < ApplicationController

  respond_to :html, :json, :js

  before_action :find_user, only: [:show, :update, :forgot_password]
  authorize_resource except: [:forgot_password]

  skip_before_action :verify_authenticity_token, if: -> {
    params[:user].try(:[], :avatar).present?
    # Make sure in `user_params` that only the avatar can pass then!
  }

  def index
    begin
      redirect_to group_path(Group.everyone)
    rescue
      raise ActiveRecord::RecordNotFound, "No basic groups are present, yet. Try `rake bootstrap:all`."
    end
  end

  def show
    set_current_title @user.title
    set_current_navable @user
    set_current_access :signed_in
    set_current_access_text :all_signed_in_users_can_read_this_user_profile

    if current_user == @user
      set_current_activity :looks_at_own_profile, @user
    else
      set_current_activity :looks_at_profile, @user
    end

    metric_logger.log_event @user.attributes.merge({name: @user.name, title: @user.title}), type: :show_user

    respond_to do |format|
      format.html
      format.json
      format.js
      format.vcf do
        current_user.add_recent_contact @user
        render text: @user.to_vcf
      end
    end
  end

  def new
    @user = User.new

    @parent_group = Group.find(params[:parent_id]) if params[:parent_type] == 'Group'
    @user.add_to_group = @parent_group.try(:id)
    @user.female = false
    @user.alias = params[:alias]
  end

  def create
    @user_params = user_params
    @basic_user_params = @user_params.select { |key, value| key.to_s.in? ['first_name', 'last_name', 'email', 'female', 'create_account'] }
    @basic_user_params[:first_name] ||= I18n.t(:first_name)
    @basic_user_params[:last_name] ||= I18n.t(:last_name)
    @user = User.create(@basic_user_params)
    if @user_params[:add_to_group]
      Group.find(@user_params[:add_to_group]).assign_user @user
      @user_params.except! :add_to_group
    end
    @user.update_attributes(@user_params)
    @user.fill_in_template_profile_information
    @user.send_welcome_email if @user.account
    redirect_to @user
  end

  def update
    @user.update_attributes(user_params)
    respond_with @user
  end

  def forgot_password
    authorize! :update, @user.account
    @user.account.send_new_password
    flash[:notice] = I18n.t(:new_password_has_been_sent_to, user_name: @user.title)
    redirect_to :back
  end

  private

  # This method returns the request parameters and their values as long as the user
  # is permitted to change them.
  #
  # This mechanism protects from mass assignment hacking and replaces the old
  # attr_accessible mechanism.
  #
  # For more information, have a look at these resources:
  #   https://github.com/rails/strong_parameters/
  #   http://railscasts.com/episodes/371-strong-parameters
  #
  def user_params
    permitted_keys = []
    if @user
      permitted_keys += [:avatar, :remove_avatar] if can? :update, @user
      unless params[:user].try(:[], :avatar).present?
        # Because if the avatar is present, the authenticity
        # token check is skipped due to:
        # https://github.com/refile/refile/issues/185
        # https://trello.com/c/BrZRMY6K/816
        #
        permitted_keys += [:first_name] if can? :change_first_name, @user
        permitted_keys += [:alias] if can? :change_alias, @user
        permitted_keys += [:email, :date_of_birth, :localized_date_of_birth] if can? :update, @user

        permitted_keys += [:last_name, :name] if can? :change_last_name, @user
        permitted_keys += [:corporation_name] if can? :manage, @user
        permitted_keys += [:create_account, :female, :add_to_group, :add_to_corporation] if can? :manage, @user
        permitted_keys += [:hidden] if can? :change_hidden, @user
        permitted_keys += [:notification_policy] if can? :update, @user
        permitted_keys += [:local_postal_mail_subscription] if can? :update, @user
      end
    else  # user creation
      permitted_keys += [:first_name, :last_name, :female, :date_of_birth, :add_to_group, :add_to_corporation, :aktivmeldungsdatum, :study_address, :home_address, :work_address, :email, :phone, :mobile, :create_account] if can? :create, User
    end
    params.require(:user).permit(*permitted_keys)
  end

  def find_user
    if not handle_mystery_user
      @user = User.find(params[:id]) if params[:id].present?
      @user ||= User.find_by_alias(params[:alias]) if params[:alias].present?
      @user ||= User.new
    end
  end

  def handle_mystery_user
    if (params[:id].to_i == 1) and (not User.where(id: 1).present?)
      redirect_to group_path(Group.everyone), :notice => "I bring order to chaos. I am the beginning, the end, the one who is many."
      return true
    end
  end

end
