concern :AddressProfileFields do

  # Scope for profile fields that are postal addresses.
  #
  def address_fields
    self.id ? profile_fields.where(type: 'ProfileFields::Address') : profile_fields.where('false')
  end

  def address_fields_json
    address_fields.to_json
  end


  def primary_address_field
    postal_address_field_or_first_address_field
  end
  def primary_address
    primary_address_field.try(:value)
  end

  # The postal address at the study location.
  #
  def study_address
    study_address_field.try(:value)
  end
  def study_address=(address_string)
    field = study_address_field
    field.value = address_string
    field.label = study_address_labels.first if field.label.in? work_or_study_address_labels
    field.save
  end
  def study_address_field
    address_fields.where(label: study_address_labels + work_or_study_address_labels).first || address_fields.build(label: study_address_labels.first)
  end
  def study_address_labels
    ["Semesteranschrift", "Studienanschrift", "Study Address"]
  end

  def work_or_study_address
    work_address || study_address
  end
  def work_or_study_address_labels
    ["Arbeits- oder Studienanschrift", "Work or Study Address"]
  end

  # The postal address of the work place.
  #
  def work_address
    work_address_field.try(:value)
  end
  def work_address=(address_string)
    field = work_address_field
    field.label = work_address_labels.first if field.label.in? work_or_study_address_labels
    field.value = address_string
    field.save
  end
  def work_address_field
    address_fields.where(label: work_address_labels + work_or_study_address_labels).first || address_fields.build(label: work_address_labels.first)
  end
  def work_address_labels
    ["Geschäftliche Anschrift", "Arbeitsanschrift", "Dienstanschrift", "Work Address"]
  end

  # The postal address of the user's home.
  #
  def home_address
    home_address_field.try(:value)
  end
  def home_address_field
    address_fields.where(label: home_address_labels).first
  end
  def home_address=(address_string)
    home_address_field.update_attributes value: address_string
  end
  def home_address_field
    address_fields.where(label: home_address_labels).first || address_fields.build(label: home_address_labels.first)
  end
  def home_address_labels
    ["Heimatanschrift", "Private Anschrift", "Home Address"]
  end

  # Primary Postal Address
  #
  def postal_address_field
    self.address_profile_fields.select do |address_field|
      address_field.postal_address? == true
    end.first
  end

  # Primary Postal Address or, if not existent, the first address field.
  #
  # First, try the address field that is flagged as :postal_address.
  # Next, try the first address field that is not empty.
  # Next, try any address field. With the new address field mechanism,
  #   the `value` field may be composed of other profile fields. In this
  #   case the datatbase attribute `value` will be empty.
  #
  def postal_address_field_or_first_address_field
    postal_address_field || address_profile_fields.where("value != ? AND NOT value IS NULL", '').first || address_profile_fields.first
  end

  # This method returns the postal address of the user.
  # If one address of the user has got a :postal_address flag, this address is used.
  # Otherwise, the first address of the user is used.
  #
  def postal_address
    postal_address_field_or_first_address_field.try(:value)
  end

  def postal_address_in_one_line
    postal_address.split("\n").collect { |line| line.strip }.join(", ") if postal_address
  end

  # Returns when the postal address has been updated last.
  #
  def postal_address_updated_at
    # if the date is earlier, the date is actually the date
    # of the data migration and should not be shown.
    #
    if postal_address_field_or_first_address_field && postal_address_field_or_first_address_field.updated_at.to_date > "2014-02-28".to_date
      postal_address_field_or_first_address_field.updated_at.to_date
    end
  end

  class_methods do

    def with_primary_address
      self.where(id: self.with_primary_address_ids)
    end
    def with_postal_address
      with_primary_address
    end

    def with_primary_address_ids
      profilables_with_address_field_with_direct_value = self.joins(:address_profile_fields).where('profile_fields.profileable_id IS NOT NULL AND profile_fields.value != ""')
      ids = self.joins(:address_profile_fields).select do |profileable|
        # The `value` is a composition of other sub-profile-fields, not necessarily written
        # to the database directly. That's why we have to double-check.
        profileable.in?(profilables_with_address_field_with_direct_value) || profileable.postal_address_field_or_first_address_field.try(:value).present?
      end.uniq.map(&:id)
    end

    def without_primary_address
      self.where.not(id: self.with_primary_address_ids)
    end
    def without_postal_address
      without_primary_address
    end

  end
end