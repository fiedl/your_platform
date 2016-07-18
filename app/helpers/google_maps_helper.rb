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
    with_info_window_class = "with_info_window" if options[:with_info_window]
    address_profile_fields = address_profile_fields.select do |pf|
      pf.type == "ProfileFieldTypes::Address"
    end
    json = address_profile_fields.to_json
    content_tag :div, class: 'map_container' do
      content_tag :div, '', class: "google_maps #{with_info_window_class}", data: {profile_fields: json}
    end
  end

end