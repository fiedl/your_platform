module ProfileFields

  class Employment < ProfileField
    def self.model_name; ProfileField.model_name; end
    
    has_child_profile_fields :from, :to, :organization, :position, :task
    
    # If the employment instance has no label, just say 'Employment'.
    #
    def label
      super || I18n.translate( :employment, default: "Employment" ) 
    end

    def from
      get_field(:from).to_date if get_field(:from)
    end

    def to
      get_field(:to).to_date if get_field(:to)
    end

  end
  
end