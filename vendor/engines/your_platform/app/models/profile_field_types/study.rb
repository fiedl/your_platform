module ProfileFieldTypes

  # Studies Information
  #
  class Study < ProfileField
    def self.model_name; ProfileField.model_name; end

    has_child_profile_fields :from, :to, :university, :subject, :specialization

    # If the single study has no label, just say 'Study'.
    #
    def label
      super || I18n.translate( :study, default: "Study" )
    end

  end
  
end