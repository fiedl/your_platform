class GroupMembersController < ApplicationController

  # https://railscasts.com/episodes/259-decent-exposure
  #
  expose :group
  expose :member_table_rows, -> {
    readable_user_ids = User.accessible_by(current_ability, :read).pluck(:id)
    name_readable_user_ids = User.accessible_by(current_ability, :read_name).pluck(:id)
    group.member_table_rows
      .select { |member_row| member_row[:user_id].in? name_readable_user_ids }
      .select { |member_row| params[:valid_from].nil? || (member_row[:joined_at] > params[:valid_from].to_datetime) }
      .collect { |member_row| member_row.merge({href: (user_path(id: member_row[:user_id]) if member_row[:user_id].in?(readable_user_ids))}) }
  }
  expose :new_membership, -> { group.build_membership }
  expose :own_memberships, -> { Membership.with_past.find_all_by_user_and_group(current_user, group) }

  def index
    authorize! :read, group

    set_current_navable group
    set_current_title "#{group.name} — #{t(:members)} (#{group.members.count})"
    set_current_activity :looks_at_member_lists, group
    set_current_access :signed_in
    set_current_access_text :all_signed_in_users_can_read_this_member_list

    set_current_tab :members
  end

  def new
    authorize! :add_group_member, group
  end

end