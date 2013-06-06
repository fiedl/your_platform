# -*- coding: utf-8 -*-
class ProfileField < ActiveRecord::Base

  attr_accessible        :label, :type, :value, :key

  belongs_to             :profileable, polymorphic: true

  # Only allow the type column to be an existing class name.
  #
  validates_each :type do |record, attr, value| 
    if value
      if not ( defined?( value.constantize ) && ( value.constantize.class == Class ) && value.start_with?( "ProfileFieldTypes::" ) )
        record.errors.add "#{value} is not a ProfileFieldTypes class."
      end
    end
  end

  # There are profile_fields that are composed of other profile_fields.
  # For example, the BankAccount profile_field type is composed.
  #
  #   BankAccount
  #        |------- ProfileField:  :label => "Account Holder"
  #        |------- ProfileField:  :label => "Account Number"
  #        |------- ProfileField:  :label => "Bank Code"
  #        |------- ProfileField:  :label => "Credit Institution"
  #        |------- ProfileField:  :label => "IBAN"
  #        |------- ProfileField:  :label => "BIC"
  #
  # You can add this structured ProfileField manually:
  #
  #    account = ProfileField.create( label: "Bank Account", type: "BankAccount" )
  #    account.children.create( label: "Account Holder", value: ... )
  #    ...
  #
  # Or, you can use the customized `create` method of the specialized class BankAccount,
  # which inherits from ProfileField, to create a blank BankAccount-type profile_field
  # with all children auto-created empty.
  #
  #    account = BankAccount.create( label: "Bank Account" )
  #
  acts_as_tree

  # Profile fields may have flags, e.g. :preferred_address.
  #
  has_many_flags

  # Often, profile_fields are to be displayed in a certain manner on a HTML page.
  # This method returns the profile_field's value as HTML code in the way
  # the profile_field should be displayed.
  #
  # Override this in the inheriting classes in ordner to modify the html output
  # of the value.
  #
  def display_html
    self.value
  end

  # This method returns the key, i.e. the un-translated label, 
  # which is needed for child profile fields.
  #
  def key
    read_attribute :label
  end
  
  # This method returns the label text of the profile_field.
  # If a translation exists, the translation is returned instead.
  #
  def label
    label_text = super
    translated_label_text = I18n.translate( label_text, :default => label_text.to_s ) if label_text
  end

  # If the field has children, their values are included in the main field's value.
  # Attention! Probably, you want to display only one in the view: The main value or the child fields.
  # 
  def value
    if children.count > 0
      ( [ super ] + children.collect { |child| child.value } ).join(", ")
    else
      super
    end
  end

  # This creates an easier way to access a composed ProfileField's child field
  # values. Instead of calling
  #
  #    bank_account.children.where( :label => :account_number ).first.value
  #    bank_account.children.where( :label => :account_number ).first.value = "12345"
  #
  # you may call
  #
  #    bank_account.account_number
  #    bank_account.account_number = "12345"
  #
  # after telling the profile_field to create these accessors:
  #
  #    class BankAccount < ProfileField
  #      ...
  #      has_child_profile_fields :account_holder, :account_number, ...
  #      ...
  #    end
  #
  # Furthermore, this method modifies the intializer to build the child fields
  # on build of the main profile_field.
  extend ProfileFieldMixins::HasChildProfileFields

  # In order to namespace the type classes of the profile_fields, we place them
  # in a module. In order to be able to use the type column without including
  # the module, this method makes sure that the module is included in the
  # type column on save.
  #
  # Both versions should work:
  #     ProfileField.create( label: "My Address", value: "...", type: "Address" )
  #     ProfileField.create( label: "My Address", value: "...", type: "ProfileField::Address" )
  #
  # The long version `ProfileField::...` is stored in the database.
  #
  before_save :include_module_in_type_column
  def include_module_in_type_column
    type = "ProfileFieldTypes::#{type}" if not type.include?( "::" ) if type
  end
  private :include_module_in_type_column

end

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
  #    Organization
  #         |--------- ProfileField:  :label => :organization
  #         |--------- ProfileField:  :label => :role
  #         |--------- ProfileField:  :label => :since_when
  #
  class Organization < ProfileField
    def self.model_name; ProfileField.model_name; end

    has_child_profile_fields :organization, :role, :since_when

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
      @geo_location ||= GeoLocation.find_or_create_by_address(value)
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
      geo_location.send( key )
    end

    def geocoded?
      (find_geo_location && @geo_location.geocoded?).to_b
    end
    def geocode
      return @geo_location.geocode if @geo_location
      return @geo_location.geocode if find_geo_location
      return find_or_create_geo_location
    end

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
      value = phone_number_str

      # determine wheter this is an international number
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

    has_child_profile_fields :text_above_name, :name_prefix, :name_postfix, :text_below_name

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
      return date_string.to_date if date_string
    end
  end


  # Academic Degree 
  # ==========================================================================================

  class AcademicDegree < ProfileField
    def self.model_name; ProfileField.model_name; end

  end

end
