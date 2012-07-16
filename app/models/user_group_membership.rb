
# In this application, all user group memberships, i.e. memberships of a certain 
# user in a certail group, are stored implicitly in the dag_links table in order
# to minimize the number of database requests that are necessary to find out
# whether a user is member in a certain group through an indirect membership.
# This class allows abstract access to the UserGroupMemberships themselves,
# and to their properties like since when the membership exists.
class UserGroupMembership
  extend ActiveModel::Naming
  include ActiveModel::MassAssignmentSecurity
  include ActiveModel::Dirty

  attr_accessible :created_at, :deleted_at

  def initialize( params = {} )

    raise "Could not initialize UserGroupMembership without user." unless params[ :user ]
    raise "Could not initialize UserGroupMembership without group." unless params[ :group ]

    @params = params
    @user = params[ :user ]
    @group = params[ :group ]
    @at_time = params[ :at_time ] # represent the membership at a certain point in time

  end

  # Returns the same representation of the membership at a certain point in time.
  # Example: earlier_membership = 
  #    UserGroupMembership.new( user: User.first, group: Group.first ).at( 30.minutes.ago )
  def at_time( time )
    UserGroupMembership.new( @params.merge( { at_time: time } ) )
  end

  def exists?
    if dag_link
      return true if deleted_at == nil # then the link exists until further notice
      return true if deleted_at >= @at_time if @at_time # then the link still exists at the given time
    end
    return false # otherwise, the link does not exist (at the given time)
  end

  def existed?
    if dag_link
      # if the dag_link exists, the link exists now or existed in the past.
      # But this method should only return `true` if the link existed in the past.
      return true if deleted_at != nil
    end
    return false
  end

  def deleted?
    return true if dag_link and not exists?
  end

  def self.create( params )
    membership = UserGroupMembership.new( params )
    if membership
      unless membership.exists?
        user = params[ :user ]
        group = params[ :group ]
        user.parent_groups << group
        membership = UserGroupMembership.new( params ) # this is required to avoid caching problem.
                                                       # Otherwise, the membership instance will use an old @dag_link.
      end
    end
    return membership
  end

  def destroy
    if self.exists?
      if dag_link.destroyable?
        dag_link.destroy
        @dag_link = nil
        @devisor_dag_link = nil
        @devisor_membership = nil
        initialize( @params )
      else
        raise "membership not destroyable."
      end
    else
      raise "membership does not exist."
    end
  end

  def user ; @user; end
  def group ; @group; end

  def created_at ; dag_link_attr( :created_at ); end
  def created_at=( created_at ); dag_link_attr( :created_at=, created_at ); end
  def deleted_at ; dag_link_attr( :deleted_at ); end
  def deleted_at=( deleted_at ) ; dag_link_attr( :deleted_at=, deleted_at ); end


  def dag_links
    links = @group.links_as_ancestor(true)
      .now_and_in_the_past
      .where( "descendant_type = ?", "User" )
      .where( "descendant_id = ?", @user.id )
    links = links.order( "created_at asc" )
    links = links.at_time( @at_time ) if @at_time
    links
  end
      
  def dag_link
    @dag_link = dag_links.last unless @dag_link
    return @dag_link
  end


  def save
    devisor_dag_link.save if devisor_dag_link
  end

  def update_attributes( values, options = {} )
    # see: http://stackoverflow.com/questions/10975370/does-activemodel-have-a-module-that-includes-an-update-attributes-method
    sanitize_for_mass_assignment( values, options[ :as ] ).each do |k, v|
      send( "#{k}=", v )
    end
    self.save
  end


  def direct?
    dag_link.direct?
  end



  def self.find_by_user_and_group( user, group )
    return UserGroupMembership.new( user: user, group: group )
  end

  # Find all UserGroupMemberships for a certain user. 
  # If the option :with_deleted is set true, also deleted memberships are found.
  def self.find_all_by_user( user, options = {} )
    links = user.links_as_descendant.where( "ancestor_type = ?", "Group" )
    links = links.with_deleted if options[ :with_deleted ] == true 
    groups = links.collect { |dag_link| Group.find( dag_link.ancestor_id ) }
    memberships = groups.collect { |group| UserGroupMembership.new( user: user, group: group ) }
    return memberships
  end

  # Find all UserGroupMemberships for a certain group.
  # If the option :with_deleted is set true, also deleted memberships are found.
  def self.find_all_by_group( group, options = {} )
    links = group.links_as_ancestor.where( "descendant_type = ?", "User" )
    links = links.with_deleted if options[ :with_deleted ] == true
    users = links.collect { |dag_link| User.find( dag_link.descendant_id ) }
    memberships = users.collect { |user| UserGroupMembership.new( user: user, group: group ) }
    return memberships
  end

  # Returns the direct membership corresponding to an indirect one.
  # If, for example, `subgroup` is a subgroup of `group` 
  # and `user` is a direct member of `subgroup`, then
  #   UserGroupMembership.new( user: user, group: group ).devisor_membership 
  #      == UserGroupMembership.new( user: user, group: subgroup )
  def devisor_membership
    unless @devisor_membership
      if dag_link.direct?
        @devisor_membership = self
      else
        shortest_path = DagLink.shortest_path_between( @group, @user )
        if shortest_path.count == 0 # then it might be a connection in the past (i.e. deleted)
          shortest_path = DagLink.with_deleted.shortest_path_between( @group, @user )
        end
        if shortest_path.count > 0 
          direct_group = shortest_path[-2] # [-2] represents that element in the path array that
                                           #   comes just before the user itself, i.e. the 
                                           #   closest group to the user.
        end
        @devisor_membership = UserGroupMembership.new( user: @user, group: direct_group )
      end
    end
    @devisor_membership
  end

  def ==( other_membership )
    return true if self.dag_link.id == other_membership.dag_link.id
  end

  # returns an array of memberships that represent the direct memberships of the given user (of self), i.e.
  # in the subgroups (of self). For example, this is used in the corporate vita.
  def direct_memberships_now_and_in_the_past
    if self == devisor_membership
      # for direct memberships, the direct memberships contain only the membership itself.
      return self 
    else
      sub_groups = self.group.descendant_groups
      sub_group_ids = sub_groups.collect { |group| group.id }
      links = user
        .links_as_child
        .now_and_in_the_past
        .where( "ancestor_type = ?", "Group" )
        .where( :direct => true )
        .find_all_by_ancestor_id( sub_group_ids )
      memberships = links.collect do |link|
        UserGroupMembership.new( user: link.descendant, group: link.ancestor )
      end
      return memberships
    end
  end


  private

  def dag_link_attr( attr_name, params = nil )
    raise "No DagLink associated." unless dag_link 
    return devisor_dag_link.send( attr_name ) if params.nil?
    devisor_dag_link.send( attr_name, params )
  end

  def devisor_dag_link
    unless @devisor_dag_link
      if dag_link.direct?
        @devisor_dag_link = dag_link
      else
        @devisor_dag_link = devisor_membership.dag_link
      end
    end
    return @devisor_dag_link
  end

end


