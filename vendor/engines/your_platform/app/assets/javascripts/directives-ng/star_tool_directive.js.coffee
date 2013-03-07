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
  template: '<div class="starred star" ng-show="starred" ng-click="unstar()">&#9733;</div>' +
            '<div class="unstarred star" ng-hide="starred" ng-click="star()">&#9734;</div>',
# templateUrl: 'some.html',
  replace: false,
  transclude: false,
  restrict: 'E',
  scope: {
    starrable_type: '@starrableType',
    starrable_id: '@starrableId',
    user_id: '@userId'
  },
  link: (scope, element, attrs)->
    scope.$watch( (->attrs.star_object), (value)->
      scope.star_object = $.parseJSON( attrs.starObject )
#      scope.star_object = $.parseJSON( attrs.starObject ) if typeof attrs.starObject == 'String'
#      scope.star_object = attrs.starObject unless scope.star_object
    )
  controller: [ "$scope", "$attrs", "Star", ($scope, $attrs, Star)->

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
    if typeof $attrs.starObject == 'undefined'
      $scope.star_object = Star.get( {
        user_id: $scope.user_id,
        starrable_type: $scope.starrable_type,
        starrable_id: $scope.starrable_id
      } )

    # Set the starred state to true if there is an star_object. Otherwise, currently
    # no star (bookmark) exists.
    #
    $scope.$watch( 'star_object', ->
      $scope.starred = true if $scope.star_object
    )

    # This method stars the object for the user, i.e. creates a bookmark.
    #
    $scope.star = ->
      $scope.starred = true
      $scope.star_object = new Star( {
        starrable_type: $scope.starrable_type,
        starrable_id: $scope.starrable_id,
        user_id: $scope.user_id
      } )
      $scope.star_object.$save()

    # This method unstars the object for the user, i.e. removes an existing bookmark.
    #
    $scope.unstar = ->
      $scope.starred = false
      new Star( $scope.star_object ).$remove()

  ]

} )

