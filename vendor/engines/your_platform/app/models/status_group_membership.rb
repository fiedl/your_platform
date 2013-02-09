# 
# This class represents the membership of a user in a status group, i.e. a subgroup of a corporation
# representing a member status, e.g. the subgroup 'guests' or 'presidents'.
#
class StatusGroupMembership < UserGroupMembership

  # Status Group Memberships do have more properties than regular memberships;
  # those new properties are, e.g., shown in the corporate_vita.
  # Since rails apparently does not support Multi Table Inheritance,
  # this associated model takes the additional properties.
  # 
  has_one :status_group_membership_info, foreign_key: 'membership_id', autosave: true

  delegate( :promoted_by_workflow, :promoted_by_workflow=,
            :promoted_on_event, :promoted_on_event=,
            to: :status_group_membership_info, allow_nil: true )

  # This is to make sure the status_group_membership_info object exists.
  # See: http://stackoverflow.com/questions/3802179/
  #accepts_nested_attributes_for :status_group_membership_info

  def status_group_membership_info
    super || build_status_group_membership_info
  end

  before_save do 
    if status_group_membership_info.changed?
      status_group_membership_info.save
    end
  end

#  def initialize
#    super
#
#    # In order to get the delegation working, the status_group_membership_info
#    # must not be nil. The ActiveRecords might not alway be triggered,
#    # since this is an inherited model. Therefore, the class initializer
#    # is used to do this, here.
#    #
#    build_status_group_membership_info unless status_group_membership_info
#  end

  # Creator
  # ==========================================================================================

  def self.create( params )
    super( params ).becomes StatusGroupMembership 
  end
    

  # Finder Methods
  # ==========================================================================================

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

  def self.find_by_user_and_group( user, group )
    super( user, group ).becomes StatusGroupMembership
  end

end
