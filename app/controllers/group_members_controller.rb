class GroupMembersController < ApplicationController
  before_action :load_and_authorize_resource
  
  def index
    authorize! :read, @group
    
    set_current_navable @group
    set_current_title "#{@group.name}: #{t(:members)}"
    set_current_activity :looks_at_member_lists, @group
    set_current_access :signed_in
    set_current_access_text :all_signed_in_users_can_read_this_member_list
    
    cookies[:group_tab] = "members"
  end
  
  private
  
  def load_and_authorize_resource
    load_and_authorize_group
    load_and_authorize_memberships
    load_members_from_memberships
    load_own_memberships
    build_new_membership
  end
  
  def load_and_authorize_group
    @group = Group.find params[:group_id]
    authorize! :read, @group
  end
  
  def load_and_authorize_memberships
    @memberships = @group.memberships_for_member_list
    @memberships = @memberships.started_after(params[:valid_from].to_datetime) if params[:valid_from].present?
    @memberships = @memberships.select { |membership| can? :read, membership.user }
  end
  
  def load_members_from_memberships
    @members = @memberships.collect { |membership| membership.user }
  end
  
  def load_own_memberships
    @own_memberships = UserGroupMembership.with_past.find_all_by_user_and_group(current_user, @group)
  end
  
  def build_new_membership
    @new_user_group_membership = @group.build_membership
  end
  
end