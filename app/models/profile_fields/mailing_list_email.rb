module ProfileFields

  # Email List Contact Information
  #
  class MailingListEmail < Email
    def self.model_name; ProfileField.model_name; end

    def display_html
      ("<i class=\"fa fa-flag fa-sm fa-users\" title=\"#{I18n.t(:mailing_list)}\"></i> " + super).html_safe
    end
  end
  
end
