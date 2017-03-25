concern :MembershipCreator do

  class_methods do

    # This is needed, because acts-as-dag only creates indirect links when called this way.
    def create(attributes = {})
      attributes[:ancestor_id] ||= attributes[:group_id] || attributes[:group].try(:id)
      attributes[:descendant_id] ||= attributes[:user_id] || attributes[:user].try(:id)
      attributes[:ancestor_type] = "Group"
      attributes[:descendant_type] = "User"
      attributes = attributes.except(:group_id, :user_id, :user, :group)
      membership = DagLink.create(attributes).becomes(Membership)

      membership.valid_from ||= Time.zone.now
      membership.save

      membership
    end

  end

  # The regular destroy method won't trigger DagLink's callbacks properly,
  # causing the former dag link bug. By calling the DagLink's destroy method
  # we'll ensure the callbacks are called and indirect memberships are destroyed
  # correctly.
  #
  def destroy
    self.becomes(DagLink).destroy
  end

end