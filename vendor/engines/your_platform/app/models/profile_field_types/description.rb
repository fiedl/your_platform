module ProfileFieldTypes

  # Description Field
  # 
  # This fields are used to display any kind of free-text descriptive information.
  #
  class Description < ProfileField
    def self.model_name; ProfileField.model_name; end

    def display_html
      ActionController::Base.helpers.simple_format self.value
    end
  end
  
end