class ProfilesController < ApplicationController
  before_action :load_profileable

  def show
    authorize! :read, @profileable

    set_current_title "#{@profileable.title}: #{t(:profile)}"
    set_current_navable @profileable
    set_current_activity :looks_at_profile, @profileable
    set_current_access :signed_in
    set_current_access_text :all_signed_in_users_can_read_this_group_profile

    cookies[:group_tab] = "profile"

    @section = params[:section] if params[:section].present?

    if @group
      @groups_with_mailing_lists = ([@group] + @group.descendant_groups.order(:id)).select do |group|
        group.mailing_lists.any?
      end
    end
  end

  private

  def load_profileable
    @group = Group.find params[:group_id] if params[:group_id]
    @user = User.find params[:user_id] if params[:user_id]
    @profileable = @user || @group
  end

end