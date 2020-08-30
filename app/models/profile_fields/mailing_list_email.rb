module ProfileFields

  # Email List Contact Information
  #
  class MailingListEmail < Email
    def self.model_name; ProfileField.model_name; end

    has_many :memberships, through: :group
  end

end
