#
# This module allows to mark a model (User, Group, ...) as profileable, i.e. have profile fields.
#
# The inclusion of this module into ActiveRecord::Base is done in
# config/initializers/active_record_navable_extension.rb.
#

module Profileable
  def has_profile_fields( options = {} )
    is_profileable(options)
  end

  def is_profileable( options = {} )
    @profile_section_titles = options[:profile_sections] || default_profile_section_titles
    has_many :profile_fields, as: :profileable, dependent: :destroy, autosave: true
    has_many :address_profile_fields, -> { where type: 'ProfileFields::Address' }, class_name: 'ProfileFields::Address', as: :profileable, dependent: :destroy, autosave: true
    include InstanceMethodsForProfileables
    include ProfileFields
    include ProfileableMixins::Address
  end

  def default_profile_section_titles
    [:contact_information, :about_myself, :study_information, :career_information,
     :organizations, :bank_account_information, :description]
  end
  def profile_section_titles
    @profile_section_titles
  end

  module InstanceMethodsForProfileables
    def profile
      @profile ||= Profile.new(self)
    end

    def profile_section_titles
      self.class.profile_section_titles
    end

    def profile_sections
      self.profile.sections
    end

    def profile_fields_by_type( type_or_types )
      profile_fields.where( type: type_or_types )
    end
  end

end
