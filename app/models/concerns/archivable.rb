concern :Archivable do
  included do

    attr_accessible :archived_at, :archived if defined? attr_accessible
    attr_accessor :archived
    
    scope :archived, -> { where('archived_at IS NOT NULL') }
    scope :not_archived, -> { where('archived_at IS NULL') }

    def archived?
      archived
    end
  
    def archived
      archived_at ? true : false
    end
  
    def archived=(new_archived_setting)
      if new_archived_setting.in? [false, 'false', 0, nil]
        self.archived_at = nil
      else
        self.archived_at = Time.zone.now
      end
    end

  end
end