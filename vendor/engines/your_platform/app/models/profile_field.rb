# -*- coding: utf-8 -*-
class ProfileField < ActiveRecord::Base
  
  attr_accessible        :label, :type, :value
  
  belongs_to             :profileable, polymorphic: true

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

  # This method returns the label text of the profile_field.
  # If a translation exists, the translation is returned instead.
  #
  def label
    label_text = super
    translated_label_text = I18n.translate( label_text, :default => label_text )
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
  #      has_child_profile_field_accessors :account_holder, :account_number, ...
  #      ...
  #    end
  #
  extend ProfileFieldMixins::HasChildProfileFieldAccessors

end



class Custom < ProfileField
  def self.model_name; ProfileField.model_name; end

end

class Organization < ProfileField
  def self.model_name; ProfileField.model_name; end
end

class Email < ProfileField
  def self.model_name; ProfileField.model_name; end

  def display_html
    ActionController::Base.helpers.mail_to self.value
  end

end

class Address < ProfileField
  def self.model_name; ProfileField.model_name; end

  # Google Maps integration
  # see: http://rubydoc.info/gems/gmaps4rails/
  acts_as_gmappable 

  def display_html
    ActionController::Base.helpers.simple_format self.value
  end

  def gmaps4rails_address
    self.value
  end

  def gmaps
    true
  end

  # TODO: resolve redundancy with class AddressString


  def latitude ;      geo_information :lat           end
  def longitude ;     geo_information :lng           end
  def country ;       geo_information :country       end
  def country_code ;  geo_information :country_code  end
  def city ;          geo_information :city          end
  def postal_code ;   geo_information :postal_code   end

  def plz
    return postal_code if country_code == "DE"
    return nil
  end

  def geo_information( key )
    @geo_information = geo_information_from_gmaps unless @geo_information
    @geo_information[ key ] if @geo_information
  end

  def bv
    address= AddressString.new self.value
    return Bv.by_address( address )
  end

  private

  def geo_information_from_gmaps
    begin
      Gmaps4rails.geocode( self.gmaps4rails_address ).first
    rescue
      return nil
      # Wenn keine Verbindung zu GoogleMaps besteht, wird hier ein Fehler auftreten,
      # der die Anwendung jedoch nicht beenden sollte. 
    end
  end

end

class BankAccount < ProfileField
  def self.model_name; ProfileField.model_name; end

  has_child_profile_field_accessors( :account_holder, :account_number, :bank_code, 
                                     :credit_institution, :iban, :bic )

  def initialize( *attrs ) 
    super( *attrs )
    if self.parent == nil  # do it only for the parent field, not the children as well
      [ :account_holder, :account_number, :bank_code, 
        :credit_institution, :iban, :bic ].each do |label|
         
        self.children.build( label: label )
      
      end
    end
  end

end

class Description < ProfileField
  def self.model_name; ProfileField.model_name; end

  def display_html
    ActionController::Base.helpers.simple_format self.value
  end

end

class Phone < ProfileField
  def self.model_name; ProfileField.model_name; end

end

class Homepage < ProfileField
  def self.model_name; ProfileField.model_name; end

  def display_html
    url = self.value
    url = "http://#{url}" unless url.starts_with? 'http://'
    ActionController::Base.helpers.link_to self.value, url
  end

end
