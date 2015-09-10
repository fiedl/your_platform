class MembershipCollection

  def where(constraints)
    @user = constraints[:user]
    @group = constraints[:group]
    return self
  end
  
  def direct
    @direct = true
    return self
  end
  
  def dag_links
    links = DagLink.where(ancestor_type: 'Group', descendant_type: 'User', direct: true)
    links = links.where(descendant_id: @user.id) if @user
    links = links.where(ancestor_id: @group.id) if @group
    return links
  end
  
  def to_a
    dag_links.collect do |direct_link|
      [ Membership.new(user: direct_link.descendant, group: direct_link.ancestor) ] + if @direct
        []
      else  # also add indirect memberships:
        if @user and not @group
          direct_link.ancestor.connected_ancestor_groups.collect do |ancestor_group|
            Membership.new(user: direct_link.descendant, group: ancestor_group)
          end
        elsif @group and not @user
          direct_link.ancestor.connected_descendant_groups.collect do |descendant_group|
            Membership.new(user: direct_link.descendant, group: descendant_group)
          end
        end
      end
    end.flatten
  end
  
  delegate :count, :first, :last, to: :to_a
  
end