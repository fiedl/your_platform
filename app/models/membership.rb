# This represents a user-group membership.
#
# Example: 
#
#      group1 --- page1 --- group2 --- group3 --- user1
#        |
#        |------- user2
#
#   In the example, user1 has two memberships, one of them direct.
#   user2 has one membership.
#
#     Membership.where(user: user1).count == 2
#     Membership.where(user: user2).count == 1
#
class Membership
  
  attr_accessor :user, :group, :valid_from, :valid_to
  
  include MembershipValidityRange
  
  def initialize(attrs = {})
    @user = attrs[:user]
    @group = attrs[:group]
    @valid_from = attrs[:valid_from]
    @valid_to = attrs[:valid_to]
  end
  
  def self.where(constraints = {})
    MembershipCollection.new.where(constraints)
  end
  
  def self.direct
    MembershipCollection.new.direct
  end
  
  def ==(other_membership)
    self.group.id == other_membership.group.id and
    self.user.id = other_membership.user.id and
    self.valid_from == other_membership.valid_from and
    self.valid_to == other_membership.valid_to
  end
  
  alias_method :eql?, :==
  
  def direct?
    dag_link ? true : false
  end
  
  concerning :Persistence do
    def save
      write_attributes_to_dag_link
      dag_link.save
    end
    
    def save!
      raise 'Cannot save! Indirect memberships are non-persistent objects.' unless direct?
      write_attributes_to_dag_link
      dag_link.save!
    end
    
    def write_attributes_to_dag_link
      dag_link.valid_from = @valid_from
      dag_link.valid_to = @valid_to
    end
  
    def reload
      @dag_link = nil
      @valid_from = dag_link.valid_from
      @valid_to = dag_link.valid_to
      return self
    end
    
    # Direct memberships are stored as DagLinks in the database.
    # This is, because we've used the acts_as_dag gem earlier:
    # https://github.com/resgraph/acts-as-dag
    # 
    # In contrast to the gem, we do not store indirect links
    # in the database anymore, since this makes write operations
    # too expensive for large graphs.
    #
    def dag_link
      @dag_link ||= DagLink.where(ancestor_type: 'Group', descendant_type: 'User', direct: true,
        ancestor_id: group.id, descendant_id: user.id).first
    end
  end
  
end