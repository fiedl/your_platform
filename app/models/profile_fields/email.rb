module ProfileFields

  # Email Contact Information
  #
  class Email < ProfileField
    validates_format_of :value, :with => Devise::email_regexp, :if => Proc.new { |pf| pf.value.present? }
    validates_uniqueness_of :value, :if => Proc.new { |pf| pf.value.present? }, case_sensitive: false

    def self.model_name; ProfileField.model_name; end

    def display_html
      mail = self.value || ""
      if mail == "—"
        mail
      else
        ActionController::Base.helpers.mail_to mail
      end
    end

    def vcard_property_type
      "EMAIL"
    end

    def fill_cache
      super
      profileable.email
    end
  end

end
