module ProfileableMixins::Address
  extend ActiveSupport::Concern
  
  # Scope for profile fields that are postal addresses.
  #
  def address_fields
    profile_fields.where(type: 'ProfileFieldTypes::Address')
  end
  
  # The postal address at the study location.
  #
  def study_address
    address_fields.where(label: study_address_labels + work_or_study_address_labels).first.try(:value)
  end
  def study_address=(address_string)
    field = address_fields.where(label: study_address_labels + work_or_study_address_labels).first || address_fields.build(label: study_address_labels.first)
    field.value = address_string
    field.label = study_address_labels.first if field.label.in? work_or_study_address_labels
    field.save
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
    address_fields.where(label: work_address_labels + work_or_study_address_labels).first.try(:value)
  end
  def work_address=(address_string)
    field = address_fields.where(label: work_address_labels + work_or_study_address_labels).first || address_fields.build(label: work_address_labels.first)
    field.label = work_address_labels.first if field.label.in? work_or_study_address_labels
    field.value = address_string
    field.save
  end
  def work_address_labels
    ["Geschäftliche Anschrift", "Arbeitsanschrift", "Dienstanschrift", "Work Address"]
  end

  # The postal address of the user's home.
  #
  def home_address
    address_fields.where(label: home_address_labels).first.try(:value)
  end
  def home_address=(address_string)
    field = address_fields.where(label: home_address_labels).first || address_fields.build(label: home_address_labels.first)
    field.value = address_string
    field.save
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
  def postal_address_field_or_first_address_field
    postal_address_field || address_profile_fields.where("value != ? AND NOT value IS NULL", '').first
  end

  # This method returns the postal address of the user.
  # If one address of the user has got a :postal_address flag, this address is used.
  # Otherwise, the first address of the user is used.
  #
  def postal_address
    cached { postal_address_field_or_first_address_field.try(:value) }
  end
  
  def postal_address_in_one_line
    postal_address.split("\n").collect { |line| line.strip }.join(", ") if postal_address
  end

  # Returns when the postal address has been updated last.
  #
  def postal_address_updated_at
    cached do
      # if the date is earlier, the date is actually the date
      # of the data migration and should not be shown.
      #
      if postal_address_field_or_first_address_field && postal_address_field_or_first_address_field.updated_at.to_date > "2014-02-28".to_date 
        postal_address_field_or_first_address_field.updated_at.to_date 
      end
    end
  end
  
  included do
  end

  module ClassMethods
    
    def with_postal_address
      self.joins(:address_profile_fields).where('profile_fields.profileable_id IS NOT NULL AND profile_fields.value != ""').uniq
    end
  
    def with_postal_address_ids
      self.with_postal_address.collect { |user| user.id }
    end
  
    def without_postal_address
      self.where('NOT users.id IN (?)', self.with_postal_address_ids)
    end
    
  end
end