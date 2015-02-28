module ProfileFieldTypes

  # Custom Contact Information
  #
  # Custom profile_fields are just key-value fields. They don't have a
  # sub-structure. They are displayed in the contact section of a profile.
  #
  class Custom < ProfileField
    def self.model_name; ProfileField.model_name; end
  end
  
end