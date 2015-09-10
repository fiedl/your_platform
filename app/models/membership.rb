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
  
end