#
# In this application, all user group memberships, i.e. memberships of a certain
# user in a certain group, are stored implicitly in the dag_links table in order
# to minimize the number of database queries that are necessary to find out
# whether a user is member in a certain group through an indirect membership.
#
# This class allows abstract access to the UserGroupMemberships themselves,
# and to their properties like since when the membership exists.
#
class UserGroupMembership < DagLink

  attr_accessible :created_at, :deleted_at, :archived_at, :created_at_date_formatted
  before_validation :ensure_correct_ancestor_and_descendant_type
  
  # Validity Range
  # ====================================================================================================

  include UserGroupMembershipMixins::ValidityRange
  include UserGroupMembershipMixins::ValidityRangeForIndirectMemberships

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
  #    membership = UserGroupMembership.create( user: u, group: g )
  #
  def self.create( params )
    if UserGroupMembership.find_by( params ).present?
      raise 'Membership already exists: id = ' + UserGroupMembership.find_by( params ).id.to_s
    else
      raise "Could not create UserGroupMembership without user." unless params[:user] || params[:user_id] || params[:user_title]
      raise "Could not create UserGroupMembership without group." unless params[ :group ] || params[:group_id]
      user = params[:user]
      user ||= User.find params[:user_id] if params[:user_id]
      user ||= User.find_by_title params[:user_title] if params[:user_title]
      group = params[ :group ]
      group ||= Group.find params[:group_id] if params[:group_id]
      
      super(ancestor_id: group.id, ancestor_type: 'Group', descendant_id: user.id, descendant_type: 'User')
      
      #user.parent_groups << group
      #return UserGroupMembership.find_by( user: user, group: group )
    end
  end


  # Finder Class Methods
  # ====================================================================================================

  # Find all memberships that match the given parameters.
  # This method returns an ActiveRecord::Relation object, which means that the result can
  # be chained with scope methods.
  #
  #     memberships = UserGroupMembership.find_all_by( user: u )
  #     memberships = UserGroupMembership.find_all_by( group: g )
  #     memberships = UserGroupMembership.find_all_by( user: u, group: g ).now
  #     memberships = UserGroupMembership.find_all_by( user: u, group: g ).in_the_past
  #     memberships = UserGroupMembership.find_all_by( user: u, group: g ).now_and_in_the_past
  #     memberships = UserGroupMembership.find_all_by( user: u, group: g ).with_deleted  # same as .now_and_in_the_past
  #
  def self.find_all_by( params )
    user = params[ :user ]
    user ||= User.find params[:user_id] if params[:user_id]
    user ||= User.find_by_title params[:user_title] if params[:user_title]
    group = params[ :group ]
    group ||= Group.find params[:group_id] if params[:group_id]
    links = UserGroupMembership
      .where( :descendant_type => "User" )
      .where( :ancestor_type => "Group" )
    links = links.where( :descendant_id => user.id ) if user
    links = links.where( :ancestor_id => group.id ) if group
    links = links.order( :created_at )
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


  # 
  # # Timestamps Methods: Beginning and end of a membership
  # # ====================================================================================================
  # 
  # def created_at
  #   return read_attribute( :created_at ) if direct?
  #   first_created_direct_membership.created_at if first_created_direct_membership
  # end
  # def created_at=( created_at )
  #   return super( created_at ) if direct?
  #   first_created_direct_membership.created_at = created_at if first_created_direct_membership
  # end
  # 
  # def deleted_at
  #   return read_attribute( :deleted_at ) if direct?
  #   return nil if direct_memberships_now.count > 0 # there are still un-deleted direct memberships
  #   last_deleted_direct_membership.deleted_at if last_deleted_direct_membership
  # end
  # def deleted_at=( deleted_at )
  #   return super( deleted_at ) if direct?
  #   last_deleted_direct_membership.deleted_at = deleted_at if last_deleted_direct_membership
  # end
  # 
  # def archived_at
  #   deleted_at
  # end
  # def archived_at=( archived_at )
  #   deleted_at = archived_at
  # end
  # 
  # # This method is used in the views, since it is more convenient just to edit the date
  # # rather then date and time when specifying the date of joining a group.
  # #
  # def created_at_date
  #   self.created_at.to_date
  # end
  # def created_at_date=( created_at_date )
  #   self.created_at = created_at_date.to_datetime
  # end
  # def created_at_date_formatted
  #   I18n.localize self.created_at_date
  # end
  # def created_at_date_formatted=( created_at_date_formatted )
  #   self.created_at_date = created_at_date_formatted
  # end


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
  #     membership = UserGroupMembership.find_by_user_and_group( user, group )
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
  #     UserGroupMembership.find_by( user: user, group: group1 ).direct_memberships.should 
  #       include( UserGroupMembership.find_by( user: user, group: group2 ) )
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
    descendant_group_ids_of_self_group = descendant_groups_of_self_group.collect { |group| group.id }
    group_ids = descendant_group_ids_of_self_group + [ self.group.id ]
    
    memberships = UserGroupMembership
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
      
    memberships = memberships.order( :valid_from )
    memberships
  end

  # Returns the direct groups shown in the figures above in the description of
  # `direct_memberships`.
  #
  def direct_groups
    direct_memberships.collect { |membership| membership.group }
  end

  def direct_memberships_now_and_in_the_past
    self.direct_memberships.now_and_in_the_past
  end
  def direct_memberships_now
    self.direct_memberships.where( :deleted_at => nil )
  end


  # # In order to set and get the correct inherited datetime of creation and deletion,
  # # one has to find the first created direct membership and the last deleted 
  # # direct membership, as shown in the following schema.
  # #
  # #
  # #     A1                                                      A2
  # #     |-- indirect membership ----------------------------------|
  # #
  # #     b1                          b2
  # #     |-- direct membership 1 -----|
  # #                                  |-- direct membership 2 -----|
  # #                                  c1                         c2
  # #
  # # The following datetimes should be the same:
  # # A1 = b1,  A2 = c2,  b2 = c1
  # #
  # def first_created_direct_membership
  #   @first_created_direct_membership ||= direct_memberships_now_and_in_the_past.reorder( :created_at ).first
  # end
  # 
  # def last_deleted_direct_membership
  #   @last_deleted_direct_membership ||= direct_memberships_now_and_in_the_past.reorder( :deleted_at ).last
  # end


  # Methods to Change the Membership
  # ====================================================================================================  

  # Destroy the current membership and move the user over to the given group.
  # 
  #    group1                       group2
  #      |---- user       =>          |---- user
  # 
  def move_to_group( group_to_move_in, options = {} )
    # date = options[:date].to_datetime if options[:date].present?
    # user_to_move = self.user
    # self.archive
    # self.update_attribute( :archived_at, date ) if date
    # new_membership = UserGroupMembership.create( user: user_to_move, group: group_to_move_in )
    # new_membership.update_attribute( :created_at, date ) if date
    # return new_membership
    
    time = (options[:time] || options[:date] || options[:at] || Time.zone.now).to_datetime
    invalidate at: time
    new_membership = UserGroupMembership.create(user: self.user, group: group_to_move_in)
    new_membership = update_attribute(:valid_from, time)
    return new_membership
  end

  def promote_to( new_group, options = {} )
    self.move_to_group( new_group, options )
  end
  

end


