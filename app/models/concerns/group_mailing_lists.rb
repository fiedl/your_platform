concern :GroupMailingLists do

  # Returns all mailing list profile fields, i.e. email addresses that
  # are used as mailing list for that group.
  #
  def mailing_lists
    self.profile_fields.where(type: 'ProfileFields::MailingListEmail')
  end

  # All mailing lists, including the ones of the sub groups.
  #
  def groups_with_mailing_lists
    ([self] + descendant_groups.order(:id)).select { |g| g.mailing_lists.any? }
  end

  def chargen_mailing_list
    chargen.mailing_lists.first if chargen
  end

  # Possible settings for the sender filter, i.e. the group attribute that determines
  # whether an incoming post is accepted or rejected.
  #
  def mailing_list_sender_filter_settings
    %w(open users_with_account corporation_members group_members officers group_officers global_officers)
  end

  def default_mailing_list_sender_filter
    if self.kind_of? OfficerGroup
      # Everyone can contact officers.
      'open'
    elsif self.corporation.present?
      # If the group has an associated corporation, all members
      # of the corporation can post.
      'corporation_members'
    else
      # If this is a regular group, all group members can post.
      'group_members'
    end
  end

  def sender_policy
    if mailing_list_sender_filter.present?
      mailing_list_sender_filter
    else
      default_mailing_list_sender_filter
    end
  end
  def sender_policy=(new_sender_policy)
    raise "#{new_sender_policy} is invalid." unless new_sender_policy.in? mailing_list_sender_filter_settings
    self.mailing_list_sender_filter = new_sender_policy
  end

  # Checks whether the given user is allowed to send an email to the mailing lists
  # of this group.
  #
  def user_matches_mailing_list_sender_filter?(user)
    case sender_policy
    when 'open'
      true
    when 'users_with_account'
      user && user.has_account?
    when 'corporation_members'
      user && user.member_of?(self.corporation)
    when 'group_members'
      user && user.member_of?(self)
    when 'officers'
      user && user.officer_of_anything?
    when 'group_officers'
      user && user.in?(self.officers)
    when 'global_officers'
      user && user.global_officer?
    else
      false
    end
  end

end