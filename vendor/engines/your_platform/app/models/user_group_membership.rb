
# In this application, all user group memberships, i.e. memberships of a certain
# user in a certail group, are stored implicitly in the dag_links table in order
# to minimize the number of database queries that are necessary to find out
# whether a user is member in a certain group through an indirect membership.
#
# This class allows abstract access to the UserGroupMemberships themselves,
# and to their properties like since when the membership exists.
class UserGroupMembership < DagLink

  attr_accessible :created_at, :deleted_at, :archived_at, :created_at_date_formatted


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
      raise "Could not create UserGroupMembership without user." unless params[ :user ]
      raise "Could not create UserGroupMembership without group." unless params[ :group ]
      user = params[ :user ]
      group = params[ :group ]
      user.parent_groups << group
      return UserGroupMembership.find_by( user: user, group: group )
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
    group = params[ :group ]
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


#  def self.find_membership_structure_by_user_and_root_group( user, group )
#    child_groups_where_the_user_is_member = group.child_group & user.ancestor_groups
#    child_hash = child_groups_where_the_user_is_member.collect do |child_group|
#      self.find_membershipself.find_membership_structure_by_user_and_root_group( user, child_group )
#    end
#    return {     
#  end


  # Temporal Scope Methods
  # ====================================================================================================

  # Return the same membership as it was/is/will be at a certain point in time.
  # This can be used, for example to get one or more memberships at a certain point in time.
  # This is a scope method and can be chained to other ActiveRecord::Relation objects.
  #
  #    UserGroupMembership.find_all_by_user( u ).at_time( 1.hour.ago )
  #    UserGroupMembership.find_all_by_user( u ).at_time( 1.hour.ago ).count
  #    UserGroupMembership.find_by( user: u, group: g ).at_time( Time.current + 30.minutes ).present?
  #
  def at_time( time )
    memberships = UserGroupMembership
      .find_all_by( user: self.user, group: self.group )
      .with_deleted
      .where( "created_at < ?", time ).where( "deleted_at IS NULL OR deleted_at > ?", time )
    return nil if memberships.count == 0
    return memberships.first if memberships.count == 1
    return memberships
  end


  # Save and Destroy Methods
  # ====================================================================================================

  # Save the current membership and auto-save also the direct memberships
  # associated with the current (maybe indirect) membership.
  #
  def save(*args)
    unless direct?
      first_created_direct_membership.save if first_created_direct_membership
      last_deleted_direct_membership.save if last_deleted_direct_membership
    end
    super(*args)
  end

  # Destroy this membership, but reload the dataset from the database in order to get access
  # to the datetime of deletion.
  # 
  def destroy
    if self.destroyable?
      super
    else
      destroy_direct_memberships
    end
#    UserGroupMembership.with_deleted.find self.id
  end

  def archive
    destroy  # using acts_as_paranoid
  end

  # This is a helper to destroy all direct memberships of this membership.
  # This is called in #destroy.
  #
  def destroy_direct_memberships
    for direct_membership in self.direct_memberships
      direct_membership.destroy
    end
  end

  # This really deletes a membership from the database. 
  # Since this won't call any callbacks, the links depending on this one are not updated,
  # meaning for reasons of database consistency, this is not to be run on 
  # links where deleted_at == nil. 
  # If you really delete a link, you have to use these two methods:
  # 
  #   link.destroy  # now it has a :deleted_at and all dependent links are updated
  #   link.delete!
  #
  def delete!
    if self.deleted_at
      DagLink.delete_all!( id: self.id ) 
    else
      raise 'for reasons of database consistency, you have to call destroy() first and then delete!().'
    end
  end

  # Status Instance Methods
  # ====================================================================================================   

  def deleted?
    return true if not UserGroupMembership.find_by( user: self.user, group: self.group )
  end


  # Timestamps Methods: Beginning and end of a membership
  # ====================================================================================================

  def created_at
    return read_attribute( :created_at ) if direct?
    first_created_direct_membership.created_at if first_created_direct_membership
  end
  def created_at=( created_at )
    return super( created_at ) if direct?
    first_created_direct_membership.created_at = created_at if first_created_direct_membership
  end

  def deleted_at
    return read_attribute( :deleted_at ) if direct?
    return nil if direct_memberships_now.count > 0 # there are still un-deleted direct memberships
    last_deleted_direct_membership.deleted_at if last_deleted_direct_membership
  end
  def deleted_at=( deleted_at )
    return super( deleted_at ) if direct?
    last_deleted_direct_membership.deleted_at = deleted_at if last_deleted_direct_membership
  end

  def archived_at
    deleted_at
  end
  def archived_at=( archived_at )
    deleted_at = archived_at
  end

  # This method is used in the views, since it is more convenient just to edit the date
  # rather then date and time when specifying the date of joining a group.
  #
  def created_at_date
    self.created_at.to_date
  end
  def created_at_date=( created_at_date )
    self.created_at = created_at_date.to_datetime
  end
  def created_at_date_formatted
    I18n.localize self.created_at_date
  end
  def created_at_date_formatted=( created_at_date_formatted )
    self.created_at_date = created_at_date_formatted
  end


  # Access Methods to Associated User and Group
  # ====================================================================================================   

  def user
    self.descendant
  end

  def group
    self.ancestor
  end

  
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
  def direct_memberships
    descendant_groups_of_self_group = self.group.descendant_groups
    descendant_group_ids_of_self_group = descendant_groups_of_self_group.collect { |group| group.id }
    group_ids = descendant_group_ids_of_self_group + [ self.group.id ]
    memberships = UserGroupMembership
      .find_all_by_user( self.user )
      .where( :direct => true )
      .where( :ancestor_id => group_ids )

    # If the membership itself is deleted, also consider the deleted direct memberships.
    # Otherwise, one has to call `direct_memberships_now_and_in_the_past` rather than
    # `direct_memberships` in order to have the deleted direct memberships included.
    #
    memberships = memberships.with_deleted if self.read_attribute( :deleted_at )
    memberships = memberships.order( :created_at )
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


  # In order to set and get the correct inherited datetime of creation and deletion,
  # one has to find the first created direct membership and the last deleted 
  # direct membership, as shown in the following schema.
  #
  #
  #     A1                                                      A2
  #     |-- indirect membership ----------------------------------|
  #
  #     b1                          b2
  #     |-- direct membership 1 -----|
  #                                  |-- direct membership 2 -----|
  #                                  c1                         c2
  #
  # The following datetimes should be the same:
  # A1 = b1,  A2 = c2,  b2 = c1
  #
  def first_created_direct_membership
    @first_created_direct_membership ||= direct_memberships_now_and_in_the_past.reorder( :created_at ).first
  end

  def last_deleted_direct_membership
    @last_deleted_direct_membership ||= direct_memberships_now_and_in_the_past.reorder( :deleted_at ).last
  end


  # Methods to Change the Membership
  # ====================================================================================================  

  # Destroy the current membership and move the user over to the given group.
  # 
  #    group1                       group2
  #      |---- user       =>          |---- user
  # 
  def move_to_group( group_to_move_in, options = {} )
    date = options[:date].to_datetime if options[:date].present?
    user_to_move = self.user
    self.archive
    self.update_attribute( :archived_at, date ) if date
    new_membership = UserGroupMembership.create( user: user_to_move, group: group_to_move_in )
    new_membership.update_attribute( :created_at, date ) if date
    return new_membership
  end

  def promote_to( new_group, options = {} )
    self.move_to_group( new_group, options )
  end
  

end


