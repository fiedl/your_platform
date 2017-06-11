class Mobile::NearbyLocationsController < Mobile::BaseController

  def index
    authorize! :read, :mobile_near_locations

    current_user.set_current_location longitude: params[:my_longitude], latitude: params[:my_latitude]
    @nearby_locations = current_user.nearby_addresses
      .as_json(only: %w(profileable_title longitude latitude value profileable_vcard_path))
  end

end