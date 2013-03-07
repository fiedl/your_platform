#
# This is the angular js controller for star lists, i.e. lists of bookmarks.
#

@app.controller( "StarListCtrl", ["$scope", "Star", ($scope, Star)->

  if not $scope.stars
    $scope.stars = Star.query( {
      user_id: $scope.user_id
    } )

] )

