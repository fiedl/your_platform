concern :PageHasSettings do

  included do
    # Easy settings: https://github.com/huacnlee/rails-settings-cached
    # For example:
    #
    #     page = Page.find(123)
    #     page.settings.color = :red
    #     page.settings.color  # =>  :red
    #
    include RailsSettings::Extend

    def settings
      PageSettings.for_thing(self)
    end
  end

  def update_attributes(attributes)
    if attributes[:settings]
      self.settings_attributes = attributes[:settings]
      attributes = attributes.except(:settings)
    end
    super(attributes)
  end

  # Original: lib/active_record/nested_attributes.rb
  #
  def settings_attributes=(attributes)
    attributes.each do |key, value|
      self.settings.send "#{key}=", value
    end
  end

end

