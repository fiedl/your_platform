concern :UserContacts do

  def add_recent_contact(contact)
    # Subtract and add in order to add the contact at the end of the array,
    # but have it uniq.
    self.recent_contacts = self.recent_contacts - [contact] + [contact]
  end

  def recent_contacts
    Rails.cache.read(recent_contacts_cache_key) || []
  end

  def recent_contacts=(contacts)
    Rails.cache.write recent_contacts_cache_key, contacts, expires_in: 2.weeks
  end

  private

  def recent_contacts_cache_key
    [self, 'recent_contacts']
  end

end