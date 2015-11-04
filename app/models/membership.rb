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
  
  # http://guides.rubyonrails.org/active_model_basics.html#model
  include ActiveModel::Model
  
  attr_accessor :user, :group, :valid_from, :valid_to
  
  include MembershipPersistence
  include MembershipValidityRange
  include MembershipValidityRangeLocalization
  include MembershipReview
  
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
    super ||
      other_membership.instance_of?(self.class) &&
      self.group.id == other_membership.group.id &&
      self.user.id == other_membership.user.id &&
      self.valid_from.try(:to_i) == other_membership.valid_from.try(:to_i) &&
      self.valid_to.try(:to_i) == other_membership.valid_to.try(:to_i)
  end
  
  alias_method :eql?, :==
  
  def direct?
    dag_link ? true : false
  end
  
  def to_param
    id.to_s
  end

  def group_id
    group.try(:id)
  end
  def group_id=(new_group_id)
    group = Group.find new_group_id
  end
  
  def user_id
    user.try(:id)
  end

  def user_title
    user.try(:title)
  end
  def user_title=(new_user_title)
    user = User.find_by_title new_user_title
  end
  
  # Invalidate the current membership and move the user to the given group.
  # 
  #     membership.move_to other_group
  #     membership.move_to other_group, at: 1.hour.ago
  #
  def move_to(group_to_move_in, options = {})
    time = (options[:time] || options[:date] || options[:at] || Time.zone.now).to_datetime
    self.invalidate at: time
    new_membership = Membership.create(user: self.user, group: group_to_move_in)
    new_membership.update_attributes valid_from: time
    return new_membership
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
      
    user.delete_cache
    group.delete_cache
      
    Membership.new(user: user, group: group, 
      valid_from: new_dag_link.valid_from, valid_to: new_dag_link.valid_to)
  end
  
  def inspect
    "Membership(user: #{user_id}, group: #{group_id})"
  end
  
end