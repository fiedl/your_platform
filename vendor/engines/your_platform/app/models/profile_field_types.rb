module ProfileFieldTypes

  # General Information Field
  # ==========================================================================================

  class General < ProfileField
    def self.model_name; ProfileField.model_name; end
  end

  

  # Custom Contact Information
  # ==========================================================================================

  # Custom profile_fields are just key-value fields. They don't have a
  # sub-structure. They are displayed in the contact section of a profile.
  #
  class Custom < ProfileField
    def self.model_name; ProfileField.model_name; end
  end


  # Organisation Membership Information
  # ==========================================================================================

  # An organization entry represents the activity of a user in an organization.
  # Such an entry could be:
  #
  #    the user is "Lead Singer" of "the Band XYZ" since "May 2007"
  #
  # Therefore, this profile_field has got a sub-structure.
  #
  #    Organization  <-- label of the parent profile field
  #         |--------- ProfileField:  :label => :from
  #         |--------- ProfileField:  :label => :to
  #         |--------- ProfileField:  :label => :role
  #
  class Organization < ProfileField
    def self.model_name; ProfileField.model_name; end

    has_child_profile_fields :from, :to, :role

  end


  # Email Contact Information
  # ==========================================================================================

  class Email < ProfileField
    def self.model_name; ProfileField.model_name; end

    def display_html
      ActionController::Base.helpers.mail_to self.value
    end

  end


  # Address Information
  # ==========================================================================================

  class Address < ProfileField
    def self.model_name; ProfileField.model_name; end

    attr_accessible :postal_address

    # Google Maps integration
    # see: http://rubydoc.info/gems/gmaps4rails/
    acts_as_gmappable

    def geo_location
      find_or_create_geo_location
    end

    def find_geo_location
      @geo_location ||= GeoLocation.find_by_address(value)
    end

    def find_or_create_geo_location
      @geo_location ||= GeoLocation.find_or_create_by_address(value) if value
    end

    def display_html
      ActionController::Base.helpers.simple_format self.value
    end

    # This is needed to display the map later.
    def gmaps4rails_address
      self.value
    end

    def gmaps
      true
    end

    def latitude ;      geo_information :latitude      end
    def longitude ;     geo_information :longitude     end
    def country ;       geo_information :country       end
    def country_code ;  geo_information :country_code  end
    def city ;          geo_information :city          end
    def postal_code ;   geo_information :postal_code   end
    def plz ;           geo_information :plz           end

    def geo_information( key )
      geo_location.send( key ) if self.value
    end

    def geocoded?
      (find_geo_location && @geo_location.geocoded?).to_b
    end
    def geocode
      return @geo_location.geocode if @geo_location
      return @geo_location.geocode if find_geo_location
      return find_or_create_geo_location
    end

    # Allow to mark one address as primary postal address.
    # 
    def postal_address
      self.has_flag? :postal_address
    end 
    def postal_address=(new_postal_address) 
      if new_postal_address != self.postal_address
        if new_postal_address
          self.clear_postal_address
          self.add_flag :postal_address
        else
          self.remove_flag :postal_address
        end
      end
    end
    def postal_address?
      self.postal_address
    end
    def clear_postal_address
      self.profileable.profile_fields.where(type: "ProfileFieldTypes::Address").each do |address_field|
        address_field.remove_flag :postal_address
      end
    end

  end


  # About Myself Field
  # ==========================================================================================

  class About < ProfileField
    def self.model_name; ProfileField.model_name; end
  end


  # Employment Fields
  # ==========================================================================================

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

  class ProfessionalCategory < ProfileField
    def self.model_name; ProfileField.model_name; end

  end

  class Competence < ProfileField
    def self.model_name; ProfileField.model_name; end

  end


  # Bank Account Information
  # ==========================================================================================

  class BankAccount < ProfileField
    def self.model_name; ProfileField.model_name; end

    has_child_profile_fields( :account_holder, :account_number, :bank_code,
                              :credit_institution, :iban, :bic )

  end


  # Description Field
  # ==========================================================================================

  # This fields are used to display any kind of free-text descriptive information.
  #
  class Description < ProfileField
    def self.model_name; ProfileField.model_name; end

    def display_html
      ActionController::Base.helpers.simple_format self.value
    end

  end


  # Phone Number Field
  # ==========================================================================================

  class Phone < ProfileField
    def self.model_name; ProfileField.model_name; end

    before_save :auto_format_value

    def self.format_phone_number( phone_number_str )
      return "" if phone_number_str.nil?
      value = phone_number_str

      # determine whether this is an international number
      format = :national
      format = :international if value.start_with?( "00" ) or value.start_with? ( "+" )

      # do only format international numbers, since for national numbers, the country
      # is unknown and each country formats its national area codes differently.
      if format == :international
        value = Phony.normalize( value ) # remove spaces etc.
        value = value[ 2..-1 ] if value.start_with?( "00" ) # because Phony can't handle leading 00
        value = value[ 1..-1 ] if value.start_with?( "+" ) # because Phony can't handle leading +
        value = Phony.formatted( value, :format => format, :spaces => ' ' )
      end
      
      return value
    end

    private
    def auto_format_value
      self.value = Phone.format_phone_number( self.value )
    end

  end


  # Name Surrounding
  # ==========================================================================================

  class NameSurrounding < ProfileField
    def self.model_name; ProfileField.model_name; end

    has_child_profile_fields :text_above_name, :name_prefix, :name_suffix, :text_below_name

  end


  # Homepage Field
  # ==========================================================================================

  class Homepage < ProfileField
    def self.model_name; ProfileField.model_name; end

    def display_html
      url = self.value || ''
      url = "http://#{url}" unless url.starts_with? 'http://'
      ActionController::Base.helpers.link_to url, url
    end

  end


  # Date Field
  # ==========================================================================================

  class Date < ProfileField
    def self.model_name; ProfileField.model_name; end

    def value
      date_string = super
      I18n.localize(date_string.to_date) if date_string.present?
    end
    
  end


  # Academic Degree 
  # ==========================================================================================

  class AcademicDegree < ProfileField
    def self.model_name; ProfileField.model_name; end

  end

end
