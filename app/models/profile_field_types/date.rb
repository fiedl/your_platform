module ProfileFieldTypes

  # Date Field
  #
  class Date < ProfileField
    def self.model_name; ProfileField.model_name; end

    def value
      date_string = super
      I18n.localize(date_string.to_date) if date_string.present?
    end
  end
  
end