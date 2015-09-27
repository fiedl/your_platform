class MembershipCollection
  
  include MembershipCollectionValidityRange

  def where(constraints)
    @user = constraints[:user]
    @group = constraints[:group]
    return self
  end
  
  def direct
    @direct = true
    @indirect = false
    return self
  end
  
  def indirect
    @indirect = true
    @direct = false
    return self
  end
  
  def uniq
    @uniq = true
    return self
  end
  
  # If a user has two memberships in a group, differing in the validity range,
  # this filter selects the first, i.e. earliest, membership for each group.
  #
  def first_per_group
    @first_per_group = true
    return self
  end
  
  # Join the validity ranges of indirect memberships.
  #
  #     group1
  #        |------- subgroup1 -----|
  #        |------- subgroup2 --- user1
  #
  # First, user1 joins subgroup1, then moves to subgroup2.
  #
  #    |-----------|                   first indirect membership in group1
  #                |---------          second indirect membership in group2
  #    |---------------------          joined indirect membership
  #
  def join_validity_ranges_of_indirect_memberships
    @join_validity_ranges_of_indirect_memberships = true
    return self
  end
  
  def to_a
    memberships = []
    memberships += find_all_direct_memberships unless @indirect
    unless @direct
      memberships += if @user and not @group
        find_all_indirect_memberships_by_user
      elsif @group and not @user
        find_all_indirect_memberships_by_group
      elsif @user and @group
        find_all_indirect_memberships_by_user_and_group
      end
    end
    memberships = memberships.uniq { |m| [m.group.id, m.user.id, m.valid_from, m.valid_to] } if @uniq
    if @first_per_group
      memberships = memberships.group_by { |m| [m.group, m.user] }.collect do |group_and_user, memberships|
        min_valid_from_to_i = memberships.collect { |m| m.valid_from.to_i }.min
        memberships.detect { |m| m.valid_from.to_i == min_valid_from_to_i }
      end
    end
    return memberships
  end
  
  def groups
    GroupCollection.new(memberships: self)
  end
  
  delegate :count, :first, :last, to: :to_a
  delegate :map, :collect, :select, :each, to: :to_a
  
  def include?(*other_memberships)
    binding.pry
    to_a.collect { |m| [m.group.id, m.user.id, m.valid_from, m.valid_to] }
    .include?(*other_memberships.collect { |m| [m.group.id, m.user.id, m.valid_from, m.valid_to] })
  end
  
  def destroy_all
    self.each do |membership|
      membership.destroy if membership.destroyable?
    end
  end
  
  private
  
  def dag_links
    dag_links_for user: @user, group: @group
  end
    
  def find_all_direct_memberships(reload = false)
    @direct_memberships = nil if reload
    @direct_memberships ||= dag_links.collect do |direct_link|
      Membership.new(user: direct_link.descendant, group: direct_link.ancestor, 
        valid_from: direct_link.valid_from, valid_to: direct_link.valid_to)
    end
  end
  
  def find_all_indirect_memberships_by_user
    if @join_validity_ranges_of_indirect_memberships
      indirect_groups = find_all_direct_memberships.collect { |m| m.group.connected_ancestor_groups }.flatten.uniq
      indirect_groups.collect do |ancestor_group|
        dag_links = dag_links_for(
          group_ids: ancestor_group.connected_descendant_group_ids, user_ids: [@user.id],
          ignore_validity_range_filters: true, no_eager_loading: true)
        Membership.new(user: @user, group: ancestor_group,
          valid_from: min_valid_from_of(dag_links), valid_to: max_valid_to_of(dag_links))
      end
    else
      find_all_direct_memberships.collect do |direct_membership|
        direct_membership.group.connected_ancestor_groups.collect do |ancestor_group|
          Membership.new(user: @user, group: ancestor_group,
            valid_from: direct_membership.valid_from, valid_to: direct_membership.valid_to)
        end
      end
    end.flatten
  end
  
  def find_all_indirect_memberships_by_group
    if @join_validity_ranges_of_indirect_memberships
      user_ids = dag_links_for(group_ids: @group.connected_descendant_group_ids, no_eager_loading: true).pluck(:descendant_id).uniq
      user_ids.collect do |user_id|
        dag_links = dag_links_for(
          group_ids: @group.connected_descendant_group_ids, user_ids: [user_id],
          ignore_validity_range_filters: true, no_eager_loading: true)
        Membership.new(user: User.find(user_id), group: @group,
          valid_from: min_valid_from_of(dag_links), valid_to: max_valid_to_of(dag_links))
      end
    else
      dag_links_for(group_ids: @group.connected_descendant_group_ids).collect do |direct_link|
        Membership.new(user: direct_link.descendant, group: @group,
          valid_from: direct_link.valid_from, valid_to: direct_link.valid_to)
      end
    end
  end
  
  def find_all_indirect_memberships_by_user_and_group
    if @join_validity_ranges_of_indirect_memberships
      dag_links = dag_links_for(
        group_ids: @group.connected_descendant_group_ids, user_ids: [@user.id],
        ignore_validity_range_filters: true, no_eager_loading: true)
      [ Membership.new(user: @user, group: @group,
          valid_from: min_valid_from_of(dag_links), valid_to: max_valid_to_of(dag_links)) ]
    else
      @group.connected_descendant_groups.collect do |descendant_group|
        dag_links_for(group: descendant_group, user: @user).collect do |link|
          Membership.new(user: @user, group: @group, valid_from: link.valid_from, valid_to: link.valid_to)
        end
      end.flatten - [nil]
    end
  end
  
  def min_valid_from_of(dag_links)
    valid_from_nil = dag_links.where(valid_from: nil).present?
    min_valid_from = valid_from_nil ? nil : dag_links.minimum(:valid_from)
  end
  
  def max_valid_to_of(dag_links)
    valid_to_nil = dag_links.where(valid_to: nil).present?
    max_valid_to = valid_to_nil ? nil : dag_links.maximum(:valid_to)
  end
  
end