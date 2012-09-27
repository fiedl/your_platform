# -*- coding: utf-8 -*-

# This extends the your_platform AddressString model.
require_dependency YourPlatform::Engine.root.join( 'app/models/address_string' ).to_s

class AddressString

  # This method returns the Bv associated with the given address.
  def bv
    Bv.by_address( self )
  end
  
end
