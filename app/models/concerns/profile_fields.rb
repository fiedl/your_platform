concern :ProfileFields do
  
  def email
    @email ||= cached { profile_fields.where(type: ['ProfileFieldTypes::Email', 'ProfileFieldTypes::MailingListEmail']).first.try(:value) }
  end
  def email=( email )
    @email = nil
    @email_profile_field = profile_fields_by_type( "ProfileFieldTypes::Email" ).first unless @email_profile_field
    @email_profile_field = profile_fields.build( type: "ProfileFieldTypes::Email", label: "email" ) unless @email_profile_field
    @email_profile_field.value = email
  end
  def email_does_not_work?
    email_needs_review? or email_empty?
  end
  def email_needs_review?
    profile_fields_by_type("ProfileFieldTypes::Email").review_needed.count > 0
  end
  def email_empty?
    not email.present?
  end
  
  def email_fields
    profile_fields.where type: 'ProfileFieldTypes::Email'
  end
  def primary_email_field
    email_fields.first
  end
  
  def phone_profile_fields
    profile_fields.where(type: 'ProfileFieldTypes::Phone').select do |field|
      not field.label.downcase.include? 'fax'
    end
  end
  
end