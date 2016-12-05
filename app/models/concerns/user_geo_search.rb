concern :UserGeoSearch do
  class_methods do

    # Find users within a certain area.
    #
    #     User.within radius_in_km: 5, around: "Friedrichstr. 26, 91054 Erlangen, Germany"
    #
    def within(params)
      geo_locations = GeoLocation.near(params[:around], params[:radius_in_km])
      profile_fields = ProfileField.where value: geo_locations.map(&:address), type: "ProfileFieldTypes::Address"
      users = profile_fields.map(&:profileable).select { |profileable| profileable.kind_of? User }
      return users
    end

  end
end