module MapHelper

  def address_fields_map( address_fields )
    json = address_fields.to_gmaps4rails
    raise 'no json generated from address fields' unless json

    marker_size = 32
    marker_size = 13 if address_fields.count > 50

    gmaps( :markers => { :data => json, :options => { marker_width: marker_size, marker_length: marker_size, draggable: true }  },
           :map_options => { :auto_adjust => true, :auto_zoom => true }
           )
  end

end
