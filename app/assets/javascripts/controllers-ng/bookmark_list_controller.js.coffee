#
# This is the angular js controller for bookmark lists.
#

@app.controller( "BookmarkListCtrl", ["$scope", "Bookmark", "current_user_bookmarks", ($scope, Bookmark, current_user_bookmarks)->

  # The bookmark objects may be provided by the ng-init attribute of the corresponding
  # controller tag. Therefore, wait 200ms for them to appear.
  #
  setTimeout( ->

    # If the bookmarks are there, upstream them to the bookmarks service to share them
    # with other controllers.
    if $scope.bookmarks
      current_user_bookmarks.fill( $scope.bookmarks )

    # If the scope's bookmarks array is empty, the bookmarks are not prepopulated
    # by the backend. In this case, fetch the bookmarks from the JSON interface.
    if not $scope.bookmarks
      if current_user_bookmarks.length == 0
        current_user_bookmarks.find_all_by_user_id( $scope.user_id )

  , 200 )

  $scope.$on( 'bookmarksChange', ->
    $scope.bookmarks = current_user_bookmarks
  )

] )

