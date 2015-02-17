module ProfileFieldTypes

  # Email Contact Information
  #
  class Email < ProfileField
    validates_format_of :value, :with => Devise::email_regexp
    
    def self.model_name; ProfileField.model_name; end

    def display_html
      mail = self.value || ""
      if mail == "—"
        mail
      else
        ActionController::Base.helpers.mail_to mail
      end
    end
  end
  
end
