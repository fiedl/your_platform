# -*- coding: utf-8 -*-

# This extends the your_platform ProfileFIeld model.
require_dependency YourPlatform::Engine.root.join( 'app/models/profile_field' ).to_s

# This is the re-opened ProfileField class. All kinds of ProfileFields
# inherit from this class.
#
class ProfileField
  
end

# Template
#
# class SpecialProfileField < ProfileField
#   def self.model_name; ProfileField.model_name; end#
#
#   def display_html
#     self.value
#   end
#
# end


# Address Information
# ==========================================================================================

class Address

  # This method returns the Bv associated with the given address.
  def bv
    AddressString.new( self.value ).bv
  end

  # The html output method is overridden here, in order to display the bv as well.
  #
  def display_html
    ActionView::Base.send( :include, Rails.application.routes.url_helpers )

    text_to_display = self.value

    if self.bv
      text_to_display = "
        <p>#{text_to_display}</p>
        <p class=\"address_is_in_bv\">
          (#{I18n.translate( :address_is_in_bv )} " + 
        ActionController::Base.helpers.link_to( self.bv.name, self.bv.becomes( Group ) ) + 
        ")
        </p>"
    end

    ActionController::Base.helpers.simple_format( text_to_display )
  end

end


# Studies Information
# ==========================================================================================

class Study < ProfileField
  def self.model_name; ProfileField.model_name; end

  has_child_profile_fields :from, :to, :university, :subject, :specialization

end

