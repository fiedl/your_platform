module ProfileFieldTypes

  # Email Contact Information
  #
  class Email < ProfileField
    def self.model_name; ProfileField.model_name; end

    def display_html
      ActionController::Base.helpers.mail_to self.value
    end
  end
  
end