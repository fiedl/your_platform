class UserGroupMembership 
  # attr_accessible :title, :body

  def initialize( params = {} ) 

    return nil unless params[ :user ] && params[ :group ]

    @user = params[ :user ]
    @group = params[ :group ]

  end

  
  def exists?
    return true if @dag_link
    return false
  end
  
  def self.create( params )
    unless UserGroupMembership.new( params ).exists?
      user = params[ :user ]
      group = params[ :group ]
      user.parent_groups << group
      return UserGroupMembership.new( params )
    end
  end
  
  def destroy
    if @dag_link.destroyable?
      @dag_link.destroy
      return nil
    else
      raise "membership not destroyable."
    end
  end


  def created_at ; dag_link_attr( :created_at ); end
  def created_at=( created_at ); dag_link_attr( :created_at=, created_at ); end
  def deleted_at ; dag_link_attr( :deleted_at ); end
  def deleted_at=( deleted_at ) ; dag_link_attr( :deleted_at, deleted_at ); end
      


  def dag_link_attr( attr_name, params = nil )
    return devisor_dag_link.send( attr_name ) if params.nil?
    return devisor_dag_link.send( attr_name, params ) 
  end



  def dag_link
    unless @dag_link
      @dag_link = @group.links_as_ancestor.where( "descendant_type = ?", "User" )
        .where( "descendant_id = ?", @user.id )
        .first
    end
    return @dag_link
  end

  def devisor_dag_link
    unless @devisor_dag_link
      if dag_link.direct?
        @devisor_dag_link = dag_link
      else
        direct_group = DagLink.shortest_path_between( @group, @user )[-2]
        devisor_membership = UserGroupMembership.new( user: @user, group: direct_group )
        @devisor_dag_link = devisor_membership.dag_link
      end
    end
    return @devisor_dag_link
  end
    
  def save
    devisor_dag_link.save if devisor_dag_link
  end



  def self.find_by_user_and_group( user, group )
    return UserGroupMembership.new( user: user, group: group )
  end

  def self.find_all_by_user( user )
    groups = user.links_as_descendant.where( "ancestor_type = ?", "Group" )
      .collect { |dag_link| Group.find( dag_link.ancestor_id ) }
    memberships = groups.collect { |group| UserGroupMembership.new( user: user, group: group ) }
    return memberships
  end

  def self.find_all_by_group( group )
    users = group.links_as_ancestor.where( "descendant_type = ?", "User" )
      .collect { |dag_link| User.find( dag_link.descendant_id ) }
    memberships = users.collect { |user| UserGroupMembership.new( user: user, group: group ) }
    return memberships
  end

end
