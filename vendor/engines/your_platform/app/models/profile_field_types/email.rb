module ProfileFieldTypes

  # Email Contact Information
  #
  class Email < ProfileField
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
