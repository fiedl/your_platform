class GroupMembersController < ApplicationController
  before_action :load_and_authorize_resource
  
  def index
    authorize! :read, @group
    
    set_current_navable @group
    set_current_title "#{@group.name}: #{t(:members)}"
    set_current_activity :looks_at_member_lists, @group
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
    
    allowed_members = @group.members.accessible_by(current_ability)
    allowed_memberships = @group.memberships.where(descendant_id: allowed_members.map(&:id))
    @memberships = @memberships & allowed_memberships
  end
  
  def load_members_from_memberships
    # Fill also the members into a separate variable.
    #
    @members = @group.members.includes(:links_as_child).where(dag_links: {id: @memberships.map(&:id)})
    
    # For some special groups, the first method of retreiving the members does not work.
    # Fallback to these slower methods:
    @members = User.includes(:links_as_child).where(dag_links: {id: @memberships.map(&:id)}) if @members.empty?
    @members = @memberships.collect { |membership| membership.user } if @members.empty?
  end
  
  def load_own_memberships
    @own_memberships = UserGroupMembership.with_past.find_all_by_user_and_group(current_user, @group)
  end
  
  def build_new_membership
    @new_user_group_membership = @group.build_membership
  end
  
end