#
# This module contains the methods of the Group model regarding the associated
# user group memberships and users, i.e. members.
#
concern :GroupMemberships do

  included do

    # User Group Memberships
    # ==========================================================================================

    # This associates all Membership objects of the group, including indirect
    # memberships.
    #
    has_many :memberships, -> { where ancestor_type: 'Group', descendant_type: 'User' },
        foreign_key: :ancestor_id

    # This associates all memberships of the group that are direct, i.e. direct
    # parent_group-child_user memberships.
    #
    has_many :direct_memberships, -> { where ancestor_type: 'Group', descendant_type: 'User', direct: true },
        foreign_key: :ancestor_id, class_name: "Membership"

    # This associates all memberships of the group that are indirect, i.e.
    # ancestor_group-descendant_user memberships, where groups are between the
    # ancestor_group and the descendant_user.
    #
    has_many :indirect_memberships, -> { where ancestor_type: 'Group', descendant_type: 'User', direct: false },
        foreign_key: :ancestor_id, class_name: "Membership"


    #  This method builds a new membership having this group (self) as group associated.
    #
    def build_membership
      direct_memberships.build(descendant_type: 'User')
    end

    # This returns the Membership object that represents the membership of the
    # given user in this group.
    #
    # options:
    #   - also_in_the_past
    #
    def membership_of(user, options = {})
      if options[:also_in_the_past]
        base = Membership.with_invalid
      else
        base = Membership
      end
      base.find_by_user_and_group(user, self)
    end

    # This returns a string of the titles of the direct members of this group. This is used
    # for in-place editing, for example.
    #
    # The string would be something like this:
    #
    #    "#{user1.title}, #{user2.title}, ..."
    #
    def direct_members_titles_string
      direct_members.collect { |user| user.title }.join( ", " )
    end

    # This sets the memberships of a group according to the given string of user titles.
    #
    # For example, after calling
    #
    #    direct_members_titles_string = "#{user1.title}, #{user2.title}",
    #
    # the users `user1` and `user2` are the only direct members of the group.
    # The memberships are removed using the standard methods, which means that the memberships
    # are only marked as deleted. See: acts_as_paranoid_dag gem.
    #
    def direct_members_titles_string=( titles_string )
      new_members_titles = titles_string.split( "," )
      new_members = new_members_titles.collect do |title|
        u = User.find_by_title( title.strip )
        self.errors.add :direct_member_titles_string, 'user not found: #{title}' unless u
        u
      end
      for member in self.direct_members
        unassign_user member unless member.in? new_members if member
      end
      for new_member in new_members
        assign_user new_member if new_member
      end
      self.touch
    end


    # User Assignment
    # ==========================================================================================

    # This assings the given user as a member to the group, i.e. this will
    # create a Membership.
    #
    def assign_user( user, options = {} )
      if user and not user.in?(self.direct_members)
        time_of_joining = options[:joined_at] || options[:at] || options[:time] || Time.zone.now
        m = Membership.create descendant_id: user.id, ancestor_id: self.id
        m.update_attributes valid_from: time_of_joining # It does not work when added in `create`.
        m
      end
    end

    # This method will remove a Membership, i.e. terminate the membership
    # of the given user in this group.
    #
    def unassign_user( user, options = {} )
      if user and user.in?(self.members)
        time_of_unassignment = options[:at] || options[:time] || Time.zone.now
        Membership.find_by(user: user, group: self).invalidate(at: time_of_unassignment)
      end
    end


    def calculate_validity_range_of_indirect_memberships
      self.indirect_memberships.where(valid_from: nil).each do |membership|
        membership.recalculate_validity_range_from_direct_memberships
        membership.save
      end
    end


    # Members
    # ==========================================================================================

    # This associates the group members (users), direct ones as well as indirect ones.
    #
    # Attention! The conditions on the `memberships` association are ignored by Rails 3
    # when generating the SQL query. This is why the conditions have to be repeated here.
    #
    has_many(:members,
      -> { where('dag_links.ancestor_type' => 'Group').uniq },
      through: :memberships,
      source: :descendant, source_type: 'User'
      )

    # This associates only the direct group members (users).
    #
    has_many(:direct_members,
      -> { where('dag_links.ancestor_type' => 'Group', 'dag_links.direct' => true).uniq },
      through: :direct_memberships,
      source: :descendant, source_type: 'User'
      )

    # This associates only the indirect group members (users).
    #
    has_many(:indirect_members,
      -> { where('dag_links.ancestor_type' => 'Group', 'dag_links.direct' => false).uniq },
      through: :indirect_memberships,
      source: :descendant, source_type: 'User'
      )

  end
end
