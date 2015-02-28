@app = angular.module( "YourPlatform", [ "ngResource" ] )

$(document).on('ready page:load', ->
  angular.bootstrap(document, ['YourPlatform'])
)
