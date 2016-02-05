# This module contains all the profile-related methods of a User.
# 
concern :UserProfile do
  
  included do
    has_profile_fields profile_sections: [:contact_information, :about_myself, :study_information, :career_information,
       :organizations, :bank_account_information]
  end

  def landline_profile_fields
    phone_profile_fields - mobile_phone_profile_fields
  end
  def mobile_phone_profile_fields
    phone_profile_fields.select do |field|
      field.label.downcase.include?('mobil') or field.label.downcase.include?('handy')
    end
  end
  
  def phone
    phone_field.try(:value)
  end
  def phone=(new_number)
    (landline_profile_fields.first || profile_fields.create(label: I18n.t(:phone), type: 'ProfileFieldTypes::Phone')).update_attributes(value: new_number)
  end
  def phone_field
    landline_profile_fields.first || phone_profile_fields.first
  end
  
  def mobile
    (mobile_phone_profile_fields + phone_profile_fields).first.try(:value)
  end
  def mobile=(new_number)
    (mobile_phone_profile_fields.first || profile_fields.create(label: I18n.t(:mobile), type: 'ProfileFieldTypes::Phone')).update_attributes(value: new_number)
  end

  def profile_field_value(label)
    profile_fields.where(label: label).first.try(:value).try(:strip)
  end
  def personal_title
    cached { profile_field_value 'personal_title' }
  end
  
  def academic_degree
    cached { profile_field_value 'academic_degree' }
  end

  def name_surrounding_profile_field
    profile_fields.where(type: "ProfileFieldTypes::NameSurrounding").first
  end
  def text_above_name
    name_surrounding_profile_field.try(:text_above_name).try(:strip)
  end
  def text_below_name
    name_surrounding_profile_field.try(:text_below_name).try(:strip)
  end
  def text_before_name
    name_surrounding_profile_field.try(:name_prefix).try(:strip)
  end
  def text_after_name
    name_surrounding_profile_field.try(:name_suffix).try(:strip)
  end
  
      
  def fill_in_template_profile_information
    self.profile_fields.create(label: :personal_title, type: "ProfileFieldTypes::General")
    self.profile_fields.create(label: :academic_degree, type: "ProfileFieldTypes::AcademicDegree")

    self.profile_fields.create(label: :work_address, type: "ProfileFieldTypes::Address")
    self.profile_fields.create(label: :phone, type: "ProfileFieldTypes::Phone") unless self.phone
    self.profile_fields.create(label: :mobile, type: "ProfileFieldTypes::Phone") unless self.mobile
    self.profile_fields.create(label: :fax, type: "ProfileFieldTypes::Phone")
    self.profile_fields.create(label: :homepage, type: "ProfileFieldTypes::Homepage")

    pf = self.profile_fields.build(label: :bank_account, type: "ProfileFieldTypes::BankAccount")
    pf.becomes(ProfileFieldTypes::BankAccount).save

    pf = self.profile_fields.create(label: :name_field, type: "ProfileFieldTypes::NameSurrounding")
      .becomes(ProfileFieldTypes::NameSurrounding)
    pf.text_above_name = ""; pf.name_prefix = "Herrn"; pf.name_suffix = ""; pf.text_below_name = ""
    pf.save
  end
  
end