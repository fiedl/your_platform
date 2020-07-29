concern :GroupMemberList do

  # This table is used when listing the members of the group
  # together with additional information:
  #
  # - first name
  # - last name
  # - name affix
  # - joined at
  #
  def member_table_rows
    Rails.cache.fetch [self.cache_key, "member_table_rows", "v2"] do
      if memberships.count == members.count
        memberships_for_member_list.reorder('valid_from ASC').collect do |membership|
          if user = membership.user
            hash = {
              user_id: user.id,
              first_name: user.first_name,
              last_name: user.last_name,
              name_affix: user.name_affix,
              joined_at: membership.valid_from,
              address_fields_json: user.address_fields_json,
              avatar_path: user.avatar_path,
              status: user.current_status_in(self),
              status_group_id: user.current_status_group_in(self).try(:id),
              direct_group_name: user.direct_groups_in(self).last.try(:name),
              direct_group_id: user.direct_groups_in(self).last.try(:id)
            }
            hash
          end
        end
      else
        members.collect do |user|
          hash = {
            user_id: user.id,
            first_name: user.first_name,
            last_name: user.last_name,
            name_affix: user.name_affix,
            joined_at: nil,
            address_fields_json: user.address_fields_json,
            avatar_path: user.avatar_path,
            status: user.current_status_in(self),
            status_group_id: user.current_status_group_in(self).try(:id),
            direct_group_name: user.direct_groups_in(self).last.try(:name),
            direct_group_id: user.direct_groups_in(self).last.try(:id)
          }
          hash
        end
      end - [nil]
    end
  end


  # This returns the memberships that appear in the member list
  # of the group.
  #
  # For a regular group, these are just the usual memberships.
  # For a corporation, the members of the 'former members' subgroup
  # of the corporation are excluded, even though they still have
  # memberships.
  #
  def membership_ids_for_member_list
    membership_ids
  end
  def memberships_for_member_list
    memberships_including_members.where(id: membership_ids_for_member_list)
  end
  def memberships_for_member_list_count
    memberships_for_member_list.count
  end

  def latest_membership_ids
    self.memberships.with_invalid.reorder('valid_from DESC').limit(10).pluck(:id)
  end
  def latest_memberships
    Membership.where(id: latest_membership_ids).includes(:descendant)
  end

  def membership_ids_this_year
    self.memberships.this_year.pluck(:id)
  end
  def memberships_this_year
    Membership.where(id: membership_ids_this_year)
  end

  def memberships_including_members
    memberships.includes(:descendant).order(valid_from: :desc)
  end

end