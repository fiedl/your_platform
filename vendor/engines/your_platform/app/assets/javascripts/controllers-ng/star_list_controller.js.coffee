#
# This is the angular js controller for star lists, i.e. lists of bookmarks.
#

@app.controller( "StarListCtrl", ["$scope", "Star", "stars", ($scope, Star, stars)->

  # The star objects may be provided by the ng-init attribute of the corresponding
  # controller tag. Therefore, wait 200ms for them to appear.
  #
  setTimeout( ->

    # If the stars are there, upstream them to the stars service to share them
    # with other controllers.
    if $scope.stars
      stars.fill( $scope.stars )

    # If the scope's stars array is empty, fetch the stars from the JSON interface.
    if not $scope.stars
      if stars.length == 0
        stars.find_all_by_user_id( $scope.user_id )

  , 200 )

  $scope.$on( 'starsChange', ->
    $scope.stars = stars
  )

] )

