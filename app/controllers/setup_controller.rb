class SetupController < ApplicationController

  # This setup page is only for the initial setup and must
  # not be shown later on.
  #
  skip_authorization_check  # suppress the regular handling by cancan
  before_action :handle_authorization

  # Initialize basic database entities such as a start page.
  #
  before_action :bootstrap

  def index
  end

  def create
    raise 'name not given' if params[:first_name].blank? or params[:last_name].blank?
    raise 'email not given' if params[:email].blank?
    raise 'no password' if params[:password].blank?
    raise 'password too short' if params[:password].length < 9
    raise 'password confirmation did not match' if params[:password] != params[:password_confirmation]

    user = User.new first_name: params[:first_name], last_name: params[:last_name]
    user.email = params[:email]
    user.generate_alias
    user.save!

    account = user.build_account
    account.password = params[:password]
    account.save!

    user.global_admin = true

    Setting.app_name = params[:application_name] if params[:application_name].present?
    Setting.support_email = params[:support_email] if params[:support_email].present?

    if params[:sub_organizations].present?
      params[:sub_organizations].split("\n").map(&:strip).each do |organization_name|
        if organization_name.present?
          corporation = Corporation.create name: organization_name
          full_members = corporation.child_groups.create name: 'full_members', type: 'StatusGroup'
          full_members.add_flag :full_members
        end
      end
      Corporation.all.first.status_groups.first.assign_user user
    end

    sign_in :user_account, account

    flash[:notice] = I18n.t(:setup_complete)
    redirect_to root_path
  end

  # This method is to update settings during setup:
  # - default locale
  #
  def update
    Setting.preferred_locale = params[:preferred_locale]

    redirect_to setup_path
  end

private

  def handle_authorization
    raise 'Setup already done. To start over, wipe your database.' if User.count > 0
  end

  def bootstrap
    if Page.count == 0

      Group.everyone
      Group.corporations_parent

      Page.create_root title: 'example.com', redirect_to: 'http://example.com'
      Page.create_intranet_root
      Page.create_help_page
      Page.create_imprint

      Page.intranet_root << Group.corporations_parent

      Workflow.find_or_create_mark_as_deceased_workflow
    end
  end

end