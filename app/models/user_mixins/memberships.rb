#
# This module contains the methods of the User model regarding the associated
# user group memberships and groups.
#
module UserMixins::Memberships

  extend ActiveSupport::Concern

  included do

    # User Group Memberships
    # ==========================================================================================

    # This associates all Membership objects of the group, including indirect
    # memberships.
    #
    has_many :memberships, -> { where ancestor_type: 'Group', descendant_type: 'User' },
         foreign_key: :descendant_id

    # This associates all memberships of the group that are direct, i.e. direct
    # parent_group-child_user memberships.
    #
    has_many :direct_memberships, -> { where ancestor_type: 'Group', descendant_type: 'User', direct: true },
         foreign_key: :descendant_id, class_name: "Membership"

    # This associates all memberships of the group that are indirect, i.e.
    # ancestor_group-descendant_user memberships, where groups are between the
    # ancestor_group and the descendant_user.
    #
    has_many :indirect_memberships, -> { where ancestor_type: 'Group', descendant_type: 'User', direct: false },
        foreign_key: :descendant_id, class_name: "Membership"


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
      -> { where('dag_links.descendant_type' => 'User').distinct },
      through: :memberships,
      source: :ancestor, source_type: 'Group'
      )

    # This associates only the direct groups.
    #
    has_many(:direct_groups,
      -> { where('dag_links.descendant_type' => 'User', 'dag_links.direct' => true).distinct },
      through: :direct_memberships,
      source: :ancestor, source_type: 'Group'
      )

    # This associates only the indirect groups.
    #
    has_many(:indirect_groups,
      -> { where('dag_links.descendant_type' => 'User', 'dag_links.direct' => false).distinct },
      through: :indirect_memberships,
      source: :ancestor, source_type: 'Group'
      )

  end

  def joined_at(group)
    begin
      group.membership_of(self).try(:valid_from)
    rescue ArgumentError => e
      membership = group.membership_of(self)
      Issue.scan membership if membership
      return membership.try(:valid_from)
    end
  end

  def date_of_joining(group)
    self.joined_at(group).try(:to_date)
  end
end

# In order to have auto-loading of sti classes work correctly,
# we need to require the descendant classes of `Membership` here.
# Otherwise, calls like `Membership.all` won't include instances
# of the subclasses like `Memberships::Status` if they haven't
# been used previously.
#
# This has caused a serious bug previously, which is discussed in:
# https://trello.com/c/VvY1q6Cs/1127-strange-validity-ranges
#
# See also:
#
# - http://guides.rubyonrails.org/autoloading_and_reloading_constants.html#autoloading-and-sti
# - http://stackoverflow.com/q/3245838/2066546
# - http://stackoverflow.com/q/18506933/2066546
#
require 'memberships/status'
