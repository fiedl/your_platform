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

end


class Study < ProfileField
  def self.model_name; ProfileField.model_name; end

end

