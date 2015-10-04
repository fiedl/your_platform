concern :GroupMailingLists do
  
  included do
    attr_accessible :mailing_list_sender_filter
  end
  
  # Returns all mailing list profile fields, i.e. email addresses that
  # are used as mailing list for that group.
  #
  def mailing_lists
    self.profile_fields.where(type: 'ProfileFieldTypes::MailingListEmail')
  end
  
  # Possible settings for the sender filter, i.e. the group attribute that determines
  # whether an incoming post is accepted or rejected.
  #
  def mailing_list_sender_filter_settings
    %w(open users_with_account corporation_members group_members officers group_officers global_officers)
  end
  
  # Checks whether the given user is allowed to send an email to the mailing lists 
  # of this group.
  #
  def user_matches_mailing_list_sender_filter?(user)
    case self.mailing_list_sender_filter.to_s
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
    when '', nil  # (default setting)
      if self.kind_of? OfficerGroup
        # Everyone can contact officers.
        true
      elsif self.corporation.present?
        # If the group has an associated corporation, all members
        # of the corporation can post.
        user && user.member_of?(self.corporation)
      else
        # If this is a regular group, all group members can post.
        user && user.member_of?(self)
      end
    else
      false
    end
  end
  
end