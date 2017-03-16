#
# In this application, all user group memberships, i.e. memberships of a certain
# user in a certain group, are stored implicitly in the dag_links table in order
# to minimize the number of database queries that are necessary to find out
# whether a user is member in a certain group through an indirect membership.
#
# This class allows abstract access to the Memberships themselves,
# and to their properties like since when the membership exists.
#
class Membership < DagLink

  before_validation :ensure_correct_ancestor_and_descendant_type

  has_many :issues, as: :reference, dependent: :destroy

  # Validity Range
  # ====================================================================================================

  include MembershipMixins::ValidityRange
  include MembershipMixins::ValidityRangeForIndirectMemberships


  # May Need Review Flag
  # ====================================================================================================

  # Some memberships may contain information that need review, e.g. when a validity range
  # was entered by assumption.
  #
  # This is stored as the flag :needs_review.
  #
  has_many_flags
  may_need_review
  attr_accessible :needs_review if defined? attr_accessible


  # General Properties
  # ====================================================================================================

  # Title, e.g. 'Membership of John Doe in GroupXY'
  #
  def title
    I18n.translate( :membership_of_user_in_group, user_name: self.user.title, group_name: self.group.name )
  end

  # Creation Class Method
  # ====================================================================================================

  # Create a membership of the `u` in the group `g`.
  #
  #    membership = Membership.create( user: u, group: g )
  #
  def self.create( params )
    if Membership.find_by( params ).present?
      raise 'Membership already exists: id = ' + Membership.find_by( params ).id.to_s
    else
      user = params[:user]
      user ||= User.find params[:user_id] if params[:user_id]
      user ||= User.find_by_title params[:user_title] if params[:user_title]
      raise "Could not create Membership without user." unless user

      group = params[ :group ]
      group ||= Group.find params[:group_id] if params[:group_id]
      raise "Could not create Membership without group." unless group

      new_membership = DagLink
        .create(ancestor_id: group.id, ancestor_type: 'Group', descendant_id: user.id, descendant_type: 'User')
        .becomes(Membership)

      # This needs to be called manually, since DagLink won't call the proper callback.
      #
      new_membership.set_valid_from_to_now(true)
      new_membership.save

      return new_membership
    end
  end


  # Finder Class Methods
  # ====================================================================================================

  # Find all memberships that match the given parameters.
  # This method returns an ActiveRecord::Relation object, which means that the result can
  # be chained with scope methods.
  #
  #     memberships = Membership.find_all_by( user: u )
  #     memberships = Membership.find_all_by( group: g )
  #     memberships = Membership.find_all_by( user: u, group: g ).now
  #     memberships = Membership.find_all_by( user: u, group: g ).in_the_past
  #     memberships = Membership.find_all_by( user: u, group: g ).now_and_in_the_past
  #
  def self.find_all_by( params )
    user = params[ :user ]
    user ||= User.find params[:user_id] if params[:user_id]
    user ||= User.find_by_title params[:user_title] if params[:user_title]
    group = params[ :group ]
    group ||= Group.find params[:group_id] if params[:group_id]
    links = Membership
      .where( :descendant_type => "User" )
      .where( :ancestor_type => "Group" )
    links = links.where( :descendant_id => user.id ) if user
    links = links.where( :ancestor_id => group.id ) if group
    links = links.order('valid_from')
    return links
  end

  # Find the first membership that matches the parameters `params`.
  # This is a shortcut for `find_all_by( params ).first`.
  # Use this, if you only expect one membership to be found.
  #
  def self.find_by( params )
    self.find_all_by( params ).limit( 1 ).first
  end

  def self.find_all_by_user( user )
    self.find_all_by( user: user )
  end

  def self.find_all_by_group( group )
    self.find_all_by( group: group )
  end

  def self.find_by_user_and_group( user, group )
    self.find_by( user: user, group: group )
  end

  def self.find_all_by_user_and_group( user, group )
    self.find_all_by( user: user, group: group )
  end

  def self.find_all
    self.where(ancestor_type: "Group", descendant_type: "User")
  end


  # Access Methods to Associated User and Group
  # ====================================================================================================

  def user
    self.descendant
  end

  def user=(new_user)
    self.descendant_id = new_user.id
    self.descendant_type = 'User'
  end

  def user_id
    self.descendant_id
  end

  def user_title
    user.try(:title)
  end
  def user_title=(new_user_title)
    self.user = User.find_by_title(new_user_title)
  end

  def group
    self.ancestor
  end

  def group_id
    self.ancestor_id
  end

  def ensure_correct_ancestor_and_descendant_type
    self.ancestor_type = 'Group'
    self.descendant_type = 'User'
  end
  private :ensure_correct_ancestor_and_descendant_type


  # Associated Corporation
  # ====================================================================================================

  # If this membership is a subgroup membership of a corporation, this method will return the
  # corporation. Otherwise, this will return nil.
  #
  # corporation
  #     |-------- group
  #                 |---( membership )---- user
  #
  #     membership = Membership.find_by_user_and_group( user, group )
  #     membership.corporation == corporation
  #
  def corporation
    if self.group && self.user
      ( ( self.group.ancestor_groups + [ self.group ] ) && self.user.corporations ).first
    end
  end


  # Access Methods to Associated Direct Memberships
  # ====================================================================================================

  # Returns the direct memberships corresponding to this membership (self).
  # For clarification, consider the following structure:
  #
  #   group1
  #     |---- group2
  #             |---- user
  #
  # user is not a direct member of group1, but an indirect member. But user is a direct member of group2.
  # Thus, this method, called on a membership of user and group1 will return the membership between
  # user and group2.
  #
  #     Membership.find_by( user: user, group: group1 ).direct_memberships.should
  #       include( Membership.find_by( user: user, group: group2 ) )
  #
  # An indirect membership can also have several direct memberships, as shown in this figure:
  #
  #   group1
  #     |--------------- group2
  #     |                  |
  #     |---- group3       |
  #             |------------- user
  #
  # Here, group2 and grou3 are children of group1. user is member of group2 and group3.
  # Hence, the indirect membership of user and group1 will include both direct memberships.
  #
  def direct_memberships(options = {})
    descendant_groups_of_self_group = self.group.descendant_groups
    descendant_group_ids_of_self_group = descendant_groups_of_self_group.pluck(:id)
    group_ids = descendant_group_ids_of_self_group + [ self.group.id ]

    memberships = Membership
    if options[:with_invalid] || self.read_attribute( :valid_to )
      # If the membership itself is invalidated, also consider the invalidated direct memberships.
      # Otherwise, one has to call `direct_memberships_now_and_in_the_past` rather than
      # `direct_memberships` in order to have the invalidated direct memberships included.
      memberships = memberships.with_invalid
    end

    memberships = memberships
      .find_all_by_user( self.user )
      .where( :direct => true )
      .where( :ancestor_id => group_ids, :ancestor_type => 'Group' )

    memberships = memberships.order('valid_from')
    memberships
  end

  def direct_memberships_now_and_in_the_past
    direct_memberships(with_invalid: true)
  end

  # Returns the direct groups shown in the figures above in the description of
  # `direct_memberships`.
  #
  def direct_groups
    direct_memberships.collect { |membership| membership.group }
  end


  # Access Methods to Associated Indirect Memberships
  # ====================================================================================================

  def indirect_memberships
    self.group.ancestor_groups.collect do |ancestor_group|
      Membership.with_invalid.find_by_user_and_group(self.user, ancestor_group)
    end.select do |item|
      item != nil
    end
  end

  # Methods to Change the Membership
  # ====================================================================================================

  # Destroy the current membership and move the user over to the given group.
  #
  #    group1                       group2
  #      |---- user       =>          |---- user
  #
  def move_to_group( group_to_move_in, options = {} )
    time = (options[:time] || options[:date] || options[:at] || Time.zone.now).to_datetime
    invalidate at: time
    group_to_move_in.assign_user self.user, at: time
  end
  def move_to(group, options = {})
    move_to_group(group, options)
  end

  def promote_to( new_group, options = {} )
    self.move_to_group( new_group, options )
  end


  # Destroy
  # ==========================================================================================

  # The regular destroy method won't trigger DagLink's callbacks properly,
  # causing the former dag link bug. By calling the DagLink's destroy method
  # we'll ensure the callbacks are called and indirect memberships are destroyed
  # correctly.
  #
  def destroy
    DagLink.where(id: self.id).first.destroy
  end


end


