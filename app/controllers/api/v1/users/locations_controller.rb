module Api::V1::Users
  class LocationsController < ApplicationController

    # POST /api/v1/users/location
    #
    #     {longitude: 10.0018, latitude: 50.605}
    #
    def create
      update
    end

    # PUT /api/v1/users/location
    #
    #     {longitude: 10.0018, latitude: 50.605}
    #
    def update
      authorize! :update, UserLocation

      current_user.set_current_location location_params
      render json: current_user.location
    end

    private

    def location_params
      params.permit(:longitude, :latitude)
    end

  end
end