concern :ProfileFields do

  def email
    @email ||= profile_fields.where(type: ['ProfileFields::Email', 'ProfileFields::MailingListEmail']).first.try(:value)
  end
  def email=( email )
    @email = nil
    @email_profile_field ||= profile_fields_by_type("ProfileFields::Email").first
    @email_profile_field ||= profile_fields.build(type: "ProfileFields::Email", label: "email")
    @email_profile_field.value = email
  end
  def email_does_not_work?
    email_needs_review? or email_empty?
  end
  def email_needs_review?
    profile_fields_by_type("ProfileFields::Email").review_needed.count > 0
  end
  def email_empty?
    not email.present?
  end

  def email_fields
    profile_fields.where type: 'ProfileFields::Email'
  end
  def primary_email_field
    email_fields.first
  end

  def phone_profile_fields
    profile_fields.where(type: 'ProfileFields::Phone').select do |field|
      not field.label.downcase.include? 'fax'
    end
  end

  def website
    unless @website
      @website = profile_fields.where(type: 'ProfileFieldTypes::Homepage').first.try(:value)
      @website = "https://#{@website}" if @website and not (@website.start_with?("http://") or @website.start_with?("https://"))
    end
    @website
  end

end