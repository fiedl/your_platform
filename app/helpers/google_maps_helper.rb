module GoogleMapsHelper
  def google_maps_api_script_tag
    unless Rails.env.test?
      javascript_include_tag google_maps_api_source #, defer: 'defer', async: 'async'
    end
  end

  def google_maps_api_source
    "https://maps.googleapis.com/maps/api/js?key=#{google_maps_api_key}" # &callback=initMap
  end

  def google_maps_api_key
    Rails.application.secrets.google_maps_api_key
  end

  def map_of_address_profile_fields(address_profile_fields, options = {})
    google_map address_profile_fields, options
  end

  def google_map(locations, options = {})
    with_info_window_class = "with_info_window" if options[:with_info_window]

    locations = [locations] if locations.kind_of? String

    data = {
      profile_fields: locations.select { |location| location.kind_of? ProfileFields::Address },
      addresses: locations.select { |location| location.kind_of? String }.collect { |address_string|
        geo_location = GeoLocation.find_or_create_by(address: address_string)
        {string: address_string, longitude: geo_location.longitude, latitude: geo_location.latitude}
      }
    }

    content_tag :div, class: 'map_container large_map_section' do
      content_tag :div, '', class: "google_maps #{with_info_window_class}", data: data
    end
  end

end