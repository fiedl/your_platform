# This is a conveniance class to access the properties of "mailing lists".
#
# The persistent data is stored in the `ProfileFields::MailingListEmail`, which
# represents the email address, which is associated with a `Group`,
# and in the `Group` and its memberships.
#
class MailingList < ProfileFields::MailingListEmail

  def email
    self.value
  end

  def name
    group_name
  end

  def group_name
    group.name_with_corporation
  end

  def group
    profileable if profileable.kind_of? Group
  end

  def members
    group.members
  end

  def members_count
    group.member_ids.count
  end

  def posts
    Post.where(sent_via: self.email)
  end

  def posts_count
    posts.count
  end

  def sender_policy
    group.mailing_list_sender_filter
  end

  def self.all
    ProfileFields::MailingListEmail.all.collect { |profile_field| profile_field.becomes(MailingList) }
  end

  def self.sti_name
    "ProfileFields::MailingListEmail"
  end

end