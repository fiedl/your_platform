class Groups::MembersWithoutEmail < Group

  def members
    User.where id: member_ids
  end

  def member_ids
    parent_groups.first.members.select { |user| not user.email.present? or user.email_needs_review? }.map(&:id)
  end

  # This is used to determine the routes for this resource.
  # http://stackoverflow.com/a/9463495/2066546
  def self.model_name
    Group.model_name
  end

end