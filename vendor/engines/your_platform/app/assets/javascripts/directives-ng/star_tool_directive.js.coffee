#
# This file specifies the star-tool directive within the angular js framework.
# This allows to add a tag that allows the user to star or unstar an navable
# object, i.e. to bookmark it.
#
# Use the tag like this:
#
#     <star-tool starrable-type="User" starrable-id="2403" user-id="382" star-object="{JSON...}" />
#
# where the arguments are as follows:
#
#     starrable-type, starrable-id      identify the object to be starred/unstarred
#     user-id                           identify the user that is starring/unstarring the object
#     star-object  (JSON)               allowes to pre-populate the star object (model instance).
#

@app.directive( "starTool", -> {
  priority: 0,
  template: '<span class="starred star" ng-show="starred" ng-click="unstarIt()">&#9733;</span>' +
            '<span class="unstarred star" ng-hide="starred" ng-click="starIt()">&#9734;</span>',
# templateUrl: 'some.html',
  replace: false,
  transclude: false,
  restrict: 'E',
  scope: true,
  link: (scope, element, attrs)->
    scope.$watch( (->attrs.star_object), (value)->
      unless scope.starrable_type or scope.starrable_id or scope.user_id or scope.star_object
        scope.starrable_type = attrs.starrableType
        scope.starrable_id = attrs.starrableId
        scope.user_id = attrs.userId
        scope.star_object = $.parseJSON( attrs.starObject )
      if scope.star
        scope.star_object = scope.star
    )
  controller: [ "$scope", "$attrs", "Star", "stars", "$rootScope", ($scope, $attrs, Star, stars, $rootScope)->

    $scope.starred = false

    # If given, use the star_object attribute to pre-populate the object.
    # Otherwise, load the object from the JSON resource.
    #
    # If the attribute is given, but there exists no star record,
    # the variable is 'null'. If not given, i.e. have to look it up,
    # the variable is 'undefined'.
    #
    # The $scope becomes available later, the $attrs are available, yet.
    # Therefore, use the $attrs, here.
    #
    # Since it is possible that the parent scope provides the star_object,
    # wait 200ms for the scope to be ready.
    #
    setTimeout( ->
      unless $scope.star_object
        if typeof $attrs.starObject == 'undefined'
          $scope.star_object = Star.get( {
            user_id: $scope.user_id,
            starrable_type: $scope.starrable_type,
            starrable_id: $scope.starrable_id
          } )
    , 200 )

    # Set the starred state to true if there is an star_object. Otherwise, currently
    # no star (bookmark) exists.
    #
    $scope.$watch( 'star_object', ->
      $scope.starred = true if $scope.star_object
    )

    # This method stars the object for the user, i.e. creates a bookmark.
    #
    $scope.starIt = ->

      # mark the current star tool element as starred, i.e. display the filled star.
      $scope.starred = true

      # create a star object
      $scope.star_object = new Star( {
        starrable_type: $scope.starrable_type,
        starrable_id: $scope.starrable_id,
        user_id: $scope.user_id
      } )

      # add the star object to the current user's list of stars,
      # i.e. display it in the bookmarks menu, instantly.
      stars.add( $scope.star_object )

      # make the star objet persistent
      $scope.star_object.$save()

    # This method unstars the object for the user, i.e. removes an existing bookmark.
    #
    $scope.unstarIt = ->
      $scope.starred = false
      stars.remove( $scope.star_object )
      new Star( $scope.star_object ).$remove()

    # Some other controller may change the stars lists.
    # This controller needs to track this in order to display the proper status.
    #
    $scope.$on( 'starsChange', ->
      if $.inArray( $scope.star_object, stars ) == -1
        $scope.starred = false
      else
        $scope.starred = true
    )

  ]

} )

