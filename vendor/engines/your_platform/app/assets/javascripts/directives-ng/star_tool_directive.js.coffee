#
# This file specifies the star-tool directive within the angular js framework.
# This allows to add a tag that allows the user to star or unstar an navable
# object, i.e. to bookmark it.
#
# Use the tag like this:
#
#     <star-tool bookmarkable-type="User" bookmarkable-id="2403" user-id="382" bookmark="{JSON object...}" />
#
# where the arguments are as follows:
#
#     bookmarkable-type, bookmarkable-id      identify the object to be starred/unstarred
#     user-id                                 identify the user that is starring/unstarring the object
#     bookmark  (JSON)                        allows to pre-populate the star object (model instance).
#

@app.directive( "starTool", -> {
  priority: 0,
  template: '<span class="starred star" ng-show="bookmarked" ng-click="unbookmarkIt()" ' +
                   'title="Click here to remove {{bookmark.bookmarkable.title}} from your list of bookmarks.">&#9733;</span>' +
            '<span class="unstarred star" ng-hide="bookmarked" ng-click="bookmarkIt()" ' +
                   'title="Click here to add {{bookmark.bookmarkable.title}} to your list of bookmarks.">&#9734;</span>',
# templateUrl: 'some.html',
  replace: false,
  transclude: false,
  restrict: 'E',
  scope: true,
  link: (scope, element, attrs)->
    scope.$watch( (->attrs.bookmark), (value)->
      unless scope.bookmarkable_type or scope.bookmarkable_id or scope.user_id or scope.bookmark
        scope.bookmarkable_type = attrs.bookmarkableType
        scope.bookmarkable_id = attrs.bookmarkableId
        scope.user_id = attrs.userId
        scope.bookmark = $.parseJSON( attrs.bookmark )
    )
  controller: [ "$scope", "$attrs", "Bookmark", "current_user_bookmarks", "$rootScope", ($scope, $attrs, Bookmark, current_user_bookmarks, $rootScope)->

    $scope.bookmarked = false

    # If given, use the bookmark attribute to pre-populate the object.
    # Otherwise, load the object from the JSON resource.
    #
    # If the attribute is given, but there exists no bookmark record,
    # the variable is 'null'. If not given, i.e. have to look it up,
    # the variable is 'undefined'.
    #
    # The $scope becomes available later, the $attrs are available, yet.
    # Therefore, use the $attrs, here.
    #
    # Since it is possible that the parent scope provides the bookmark,
    # wait 200ms for the scope to be ready.
    #
    setTimeout( ->
      unless $scope.bookmark
        if typeof $attrs.bookmark == 'undefined'
          $scope.bookmark = Bookmark.get( {
            user_id: $scope.user_id,
            bookmarkable_type: $scope.bookmarkable_type,
            bookmarkable_id: $scope.bookmarkable_id
          } )
    , 200 )

    # Set the bookmarked state to true if there is a bookmark. Otherwise, currently
    # no bookmark exists.
    #
    $scope.$watch( 'bookmark', ->
      $scope.bookmarked = true if $scope.bookmark
    )

    # This method bookmarks the object for the user, i.e. creates a bookmark.
    #
    $scope.bookmarkIt = ->

      # mark the current star tool element as bookmarked, i.e. display the filled star.
      $scope.bookmarked = true

      # create a bookmark object
      $scope.bookmark = new Bookmark( {
        bookmarkable_type: $scope.bookmarkable_type,
        bookmarkable_id: $scope.bookmarkable_id,
        user_id: $scope.user_id
      } )

      # add the bookmark object to the current user's list of bookmarks,
      # i.e. display it in the bookmarks menu, instantly.
      current_user_bookmarks.add( $scope.bookmark )

      # make the bookmark objet persistent
      $scope.bookmark.$save()

    # This method unbookmarks the object for the user, i.e. removes an existing bookmark.
    #
    $scope.unbookmarkIt = ->
      $scope.bookmarked = false
      current_user_bookmarks.remove( $scope.bookmark )
      new Bookmark( $scope.bookmark ).$remove()

    # Some other controller may change the bookmarks lists.
    # This controller needs to track this in order to display the proper status.
    #
    $scope.$on( 'bookmarksChange', ->
      if $.inArray( $scope.bookmark, current_user_bookmarks ) == -1
        $scope.bookmarked = false
      else
        $scope.bookmarked = true
    )

  ]

} )

