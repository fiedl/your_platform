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
  include MembershipValidityRangeLocalization
  
  def initialize(attrs = {})
    @dag_link = attrs[:dag_link]
    @user = @dag_link.try(:descendant) || attrs[:user]
    @group = @dag_link.try(:ancestor) || attrs[:group]
    @valid_from = @dag_link.try(:valid_from) || attrs[:valid_from]
    @valid_to = @dag_link.try(:valid_to) || attrs[:valid_to]
  end
  
  def self.where(constraints = {})
    MembershipCollection.new.where(constraints)
  end
  
  # This represents a single direct membership, which is identified by the id of the
  # dag link that connects the user and the group of the membership.
  #
  def self.find(id)
    if link = DagLink.find(id)
      Membership.new(dag_link: link)
    else
      nil
    end
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
    def id
      dag_link.try(:id)
    end
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
  
  # Create a membership of the user `u` in the group `g`.
  #
  #    membership = Membership.create(user: u, group: g)
  #    membership = Membership.create(user: u, group: g, valid_from: 1.month_ago, valid_to: 1.day.ago)
  #
  def self.create(params)
    user = params[:user]
    user ||= User.find params[:user_id] if params[:user_id]
    user ||= User.find_by_title params[:user_title] if params[:user_title]
    raise "Could not create Membership without user." unless user
    
    group = params[ :group ]
    group ||= Group.find params[:group_id] if params[:group_id]
    raise "Could not create Membership without group." unless group
    
    new_dag_link = DagLink.create!(ancestor_id: group.id, ancestor_type: 'Group', 
      descendant_id: user.id, descendant_type: 'User',
      valid_from: params[:valid_from] || Time.zone.now,
      valid_to: params[:valid_to])
      
    Membership.new(user: user, group: group, 
      valid_from: new_dag_link.valid_from, valid_to: new_dag_link.valid_to)
  end
end