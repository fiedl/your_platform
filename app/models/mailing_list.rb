# This is a conveniance class to access the properties of "mailing lists".
#
# The persistent data is stored in the `ProfileFields::MailingListEmail`, which
# represents the email address, which is associated with a `Group`,
# and in the `Group` and its memberships.
#
class MailingList < ProfileFields::MailingListEmail
  self.table_name = "profile_fields"

  def email
    self.value
  end

  def name
    group_name
  end

  def group_name
    group.name_with_corporation
  end

  def members_count
    group.memberships.length
  end

  def posts
    if self.email.present?
      Post.where(sent_via: self.email)
    else
      Post.none
    end
  end

  def posts_count
    posts.count
  end

  def sender_policy
    group.sender_policy
  end

  def self.all
    ProfileFields::MailingListEmail.includes(:group, :memberships).order(value: :asc).all.collect { |profile_field| profile_field.becomes(MailingList) }
  end

  def self.sti_name
    "ProfileFields::MailingListEmail"
  end

end