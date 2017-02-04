#
# This module contains the methods of the User model regarding the associated
# user group memberships and groups.
#
module UserMixins::Memberships

  extend ActiveSupport::Concern

  included do

    # User Group Memberships
    # ==========================================================================================

    # This associates all UserGroupMembership objects of the group, including indirect
    # memberships.
    #
    has_many( :memberships,
              -> { where ancestor_type: 'Group', descendant_type: 'User' },
              class_name: 'UserGroupMembership',
              foreign_key: :descendant_id )

    # This associates all memberships of the group that are direct, i.e. direct
    # parent_group-child_user memberships.
    #
    has_many( :direct_memberships,
              -> { where ancestor_type: 'Group', descendant_type: 'User', direct: true },
              class_name: 'UserGroupMembership',
              foreign_key: :descendant_id )

    # This associates all memberships of the group that are indirect, i.e.
    # ancestor_group-descendant_user memberships, where groups are between the
    # ancestor_group and the descendant_user.
    #
    has_many( :indirect_memberships,
              -> { where ancestor_type: 'Group', descendant_type: 'User', direct: false },
              class_name: 'UserGroupMembership',
              foreign_key: :descendant_id )


    # This returns the membership of the user in the given group if existant.
    #
    def membership_in( group )
      memberships.where(ancestor_id: group.id).limit(1).first
    end


    # Groups the user is member of
    # ==========================================================================================

    # This associates the groups the user is member of, direct as well as indirect.
    #
    has_many(:groups,
      -> { where('dag_links.descendant_type' => 'User').uniq },
      through: :memberships,
      source: :ancestor, source_type: 'Group'
      )

    # This associates only the direct groups.
    #
    has_many(:direct_groups,
      -> { where('dag_links.descendant_type' => 'User', 'dag_links.direct' => true).uniq },
      through: :direct_memberships,
      source: :ancestor, source_type: 'Group'
      )

    # This associates only the indirect groups.
    #
    has_many(:indirect_groups,
      -> { where('dag_links.descendant_type' => 'User', 'dag_links.direct' => false).uniq },
      through: :indirect_memberships,
      source: :ancestor, source_type: 'Group'
      )

  end

  def joined_at(group)
    Rails.cache.fetch [self, 'joined_at', group] do
      group.membership_of(self).valid_from
    end
  end

  def date_of_joining(group)
    Rails.cache.fetch [self, 'date_of_joining', group] do
      self.joined_at(group).try(:to_date)
    end
  end
end
