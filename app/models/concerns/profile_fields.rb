concern :ProfileFields do

  included do
    has_many :profile_fields, as: :profileable, dependent: :destroy, autosave: true
    has_many :address_profile_fields, -> { where type: 'ProfileFields::Address' }, class_name: 'ProfileFields::Address', as: :profileable, dependent: :destroy, autosave: true
    has_many :phone_and_fax_fields, -> { where(type: 'ProfileFields::Phone') }, class_name: 'ProfileFields::Phone', as: :profileable, dependent: :destroy, autosave: true
    has_many :fax_profile_fields, -> { where(type: 'ProfileFields::Phone').where_like label: "fax" }, class_name: 'ProfileFields::Phone', as: :profileable, dependent: :destroy, autosave: true
    has_many :phone_profile_fields, -> { where(type: 'ProfileFields::Phone').where.not(id: where_like(label: "fax")) }, class_name: 'ProfileFields::Phone', as: :profileable, dependent: :destroy, autosave: true
    has_many :mobile_phone_profile_fields, -> { where(type: 'ProfileFields::Phone').where_like(label: ["mobil", "handy"]) }, class_name: 'ProfileFields::Phone', as: :profileable, dependent: :destroy, autosave: true
    has_many :email_fields, -> { where(type: 'ProfileFields::Email') }, class_name: 'ProfileFields::Email', as: :profileable, dependent: :destroy, autosave: true
    has_many :email_and_mailing_list_fields, -> { where(type: ['ProfileFields::Email', 'ProfileFields::MailingListEmail']) }, class_name: 'ProfileField', as: :profileable, dependent: :destroy, autosave: true
    has_many :description_fields, -> { where(type: 'ProfileFields::Description') }, class_name: 'ProfileFields::Description', as: :profileable, dependent: :destroy, autosave: true

    include AddressProfileFields
  end

  def email
    email_and_mailing_list_fields.first.try(:value)
  end
  def email=(new_email)
    email_profile_field = email_and_mailing_list_fields.first
    if new_email.nil?
      email_profile_field.try(:destroy)
    else
      email_profile_field ||= email_and_mailing_list_fields.build(type: "ProfileFields::Email", label: "email")
      email_profile_field.value = new_email
    end
  end
  def email_does_not_work?
    email_needs_review? or email_empty?
  end
  def email_needs_review?
    email_and_mailing_list_fields.review_needed.count > 0
  end
  def email_empty?
    not email.present?
  end

  def primary_email_field
    email_fields.first
  end

  def phone_fields
    phone_profile_fields
  end

  def landline_profile_fields
    phone_profile_fields - mobile_phone_profile_fields
  end

  def phone
    if landline_profile_fields.first.try(:value).present?
      landline_profile_fields.first.value
    else
      mobile
    end
  end
  def phone=(new_number)
    (landline_profile_fields.first || phone_and_fax_fields.create(label: I18n.t(:phone), type: 'ProfileFields::Phone')).update_attributes(value: new_number)
    phone_profile_fields.reload
  end
  def phone_field
    landline_profile_fields.first || phone_profile_fields.first
  end

  def mobile
    (mobile_phone_profile_fields + phone_profile_fields).first.try(:value)
  end
  def mobile=(new_number)
    (mobile_phone_profile_fields.first || phone_and_fax_fields.create(label: I18n.t(:mobile), type: 'ProfileFields::Phone')).update_attributes(value: new_number)
  end

  def website_fields
    profile_fields.where(type: 'ProfileFields::Homepage')
  end

  def website
    unless @website
      @website = website_fields.first.try(:value)
      @website = "https://#{@website}" if @website and not (@website.start_with?("http://") or @website.start_with?("https://"))
    end
    @website
  end

  def employment_title
    profile_fields.where(type: "ProfileFields::ProfessionalCategory", label: "employment_title").pluck(:value).join(", ")
  end

  def bank_account
    profile_fields.where(type: "ProfileFields::BankAccount").first
  end

end