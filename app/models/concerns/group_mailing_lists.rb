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
end