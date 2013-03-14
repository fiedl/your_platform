# -*- coding: utf-8 -*-

# This extends the your_platform GeoLocation model.
require_dependency YourPlatform::Engine.root.join( 'app/models/geo_location' ).to_s

class GeoLocation

  # This method returns the Bezirksverband (BV) associated with the given address.
  #
  def bv
    Bv.by_geo_location( self )
  end

end
