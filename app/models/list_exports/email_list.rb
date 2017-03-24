module ListExports

  # This class produces an email list export, one row per email address
  # rather than one row per user. One user may have several email addresses.
  #
  class EmailList < Base

    def columns
      [
        :last_name,
        :first_name,
        :name_affix,
        :email_label,
        :email_address,
        :member_since
      ]
    end

    # For the email list, one row represents one email address of a user,
    # not a user. I.e. there can be several rows per user.
    #
    def data
      super.collect { |user|
        user.profile_fields.where(type: 'ProfileFields::Email').collect { |email_field| {
          :last_name          => user.last_name,
          :first_name         => user.first_name,
          :name_affix         => user.name_affix,
          :email_label        => email_field.label,
          :email_address      => email_field.value,
          :member_since       => (I18n.localize(user.date_of_joining(group)) if user.date_of_joining(group))
        } }
      }.flatten
    end

  end
end