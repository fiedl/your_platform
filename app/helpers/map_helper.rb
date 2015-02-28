module MapHelper

  def address_fields_map( address_fields )
    json = address_fields.to_gmaps4rails do |address_field, marker|
      marker.title address_field.profileable.title
      if address_field.profileable.kind_of? Group
        marker.picture({
          picture: image_path("img/gmaps_yellow_marker_38.png"),
          width: 22, height: 38
        })
      end
    end
      
    raise 'no json generated from address fields' unless json

    #    marker_size = 32
    #    marker_size = 13 if address_fields.count > 50
    # { marker_width: marker_size, marker_length: marker_size, draggable: true }  },

    marker_options = {}
    gmaps( :markers => { :data => json, :options => marker_options },
           :map_options => { :auto_adjust => true, :auto_zoom => true }
           )
  end

end
