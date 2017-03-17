concern :StatusMembershipFinders do
  class_methods do

    # Returns all memberships in status groups that belong to the given corporation.
    #
    # corporation A
    #      |------------- status group 1
    #      |                      |-------- user 1
    #      |                      |-------- user 2
    #      |------------- status group 2
    #                             |-------- user 3
    #
    # The method therefore will return all memberships of subgroups of the corporation.
    #
    def find_all_by_corporation(corporation)
      self.where(ancestor_id: corporation.status_group_ids).order(:valid_from)
    end

    def find_all_by_user(user)
      self.where(descendant_id: user.id).order(:valid_from)
    end

    def find_all_by_user_and_corporation(user, corporation)
      self.where(ancestor_id: corporation.status_group_ids, descendant_id: user.id).order(:valid_from)
    end

    def find_by_user_and_group(user, group)
      self.where(ancestor_id: group.id, descendant_id: user.id).last
    end

  end
end