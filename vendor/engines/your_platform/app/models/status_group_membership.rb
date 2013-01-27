# 
# This class represents the membership of a user in a status group, i.e. a subgroup of a corporation
# representing a member status, e.g. the subgroup 'guests' or 'presidents'.
#
class StatusGroupMembership < UserGroupMembership

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
  def self.find_all_by_corporation( corporation )
    raise 'Expect parameter to be a Corporation' unless corporation.kind_of? Corporation
    status_groups = corporation.status_groups
    status_group_ids = status_groups.collect { |group| group.id }
    links = StatusGroupMembership
      .where( :descendant_type => "User" )
      .where( :ancestor_type => "Group" )
      .where( :ancestor_id => status_group_ids )
      .order( :created_at )
    return links
  end

  # Returns all memberships of the given user in status groups.
  #
  def self.find_all_by_user( user )
    raise 'Expect parameter to be a User' unless user.kind_of? User
    status_groups = user.status_groups
    status_group_ids = status_groups.collect { |group| group.id }
    links = StatusGroupMembership
      .where( :descendant_type => "User" )
      .where( :descendant_id => user.id )
      .where( :ancestor_type => "Group" )
      .where( :ancestor_id => status_group_ids )
      .order( :created_at )
    return links
  end

  # Returns all memberships of the given user in the given corporation.
  #
  def self.find_all_by_user_and_corporation( user, corporation )
    self.find_all_by_user( user ).find_all_by_corporation( corporation )
  end

end
