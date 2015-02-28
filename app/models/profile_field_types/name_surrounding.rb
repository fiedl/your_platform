module ProfileFieldTypes

  # Name Surrounding
  #
  class NameSurrounding < ProfileField
    def self.model_name; ProfileField.model_name; end

    has_child_profile_fields :text_above_name, :name_prefix, :name_suffix, :text_below_name
  end
  
end