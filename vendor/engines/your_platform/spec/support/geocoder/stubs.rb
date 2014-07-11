Geocoder::Lookup::Test.add_stub(
    "Pariser Platz 1\n 10117 Berlin", [
    {
        latitude: 52.5163,
        longitude: 13.3778,
        address: "Pariser Platz 1\n 10117 Berlin",
        state: 'Berlin',
        state_code: 'BER',
        country: 'Germany',
        country_code: 'DE',
        city: 'Berlin',
        postal_code: '10117'
    }
]
)
Geocoder::Lookup::Test.add_stub(
    "44 Rue de Stalingrad, Grenoble, Frankreich", [
    {
        latitude: 45.178876,
        longitude: 5.726019,
        address: "44 Rue de Stalingrad, Grenoble, Frankreich",
        state: 'Grenoble',
        state_code: 'GRE',
        country: 'France',
        country_code: 'FR',
        city: 'Grenoble',
        postal_code: '38000'
    }
]
)
Geocoder::Lookup::Test.add_stub(
    "Some Address", [
      {
          latitude: 52.5163,
          longitude: 13.3778,
          address: "Pariser Platz 1\n 10117 Berlin",
          state: 'Berlin',
          state_code: 'BER',
          country: 'Germany',
          country_code: 'DE',
          city: 'Berlin',
          postal_code: '10117'
      }
]
)
Geocoder::Lookup::Test.add_stub(
    "Some Other Address", [
    {
        latitude: 45.178876,
        longitude: 5.726019,
        address: "44 Rue de Stalingrad, Grenoble, Frankreich",
        state: 'Grenoble',
        state_code: 'GRE',
        country: 'France',
        country_code: 'FR',
        city: 'Grenoble',
        postal_code: '38000'
    }
]
)
