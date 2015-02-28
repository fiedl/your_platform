#
# This file specifies the box directive within the angular js framework.
# This directive allows to add box elements, i.e. certain sections, to the
# html structure:
#
#    <box caption="The header of the box">
#      This content is displayed <strong>inside the box</strong>.
#    </box>
#
# If editable elements are added inside the box, the box will show an
# 'edit' button that toggles all editable fields within the box.
# Therefore, editable elements have to let the box know that they are there:
#
#    # within the scope of the editable element's controller
#    $scope.box_scope().$broadcast( 'inPlaceEditorInitiated' )  # or:
#    $scope.box_scope().$broadcast( 'editableElementInitiated' )
#
# TODO:
# - das directive-template muss in eine Datei
# - die erste box braucht noch ein "first"-css-Attribut.
#

@app.directive( "box", -> {
  priority: 0,
  template: '<div class="box" ng-controller="BoxCtrl">' +
              '<div class="head"><table><tr>' +
                '<td class="box_heading">' +
                  '<h1>{{caption}} </h1>' + # the space in the h1 is really needed!
                '</td>' +
                '<td class="box_toolbar">' +
                  '<button class="btn" type="button" data-toggle="button" ng-click="toggleEditMode()" ng-show="editablesInside">' +
                    '<i class="icon-edit icon-black"></i> ' +
                    'Edit' +
                  '</button>' +
                '</td>' +
              '</tr></table></div>' +
              '<div class="divider"></div>' +
              '<div class="content" ng-transclude></div>' +
            '</div>',
# templateUrl: 'some.html',
  replace: false,
  transclude: true,
  restrict: 'E',
  #
  # the scope structure looks like this:
  #
  #    some_div_controller_scope
  #            |---------------- box_scope
  #            |                     |------ BoxCtrl_scope
  #            |
  #            |---------------- transclude_scope
  #
  # whereas the DOM structure looks like this:
  #
  #    some_div
  #       |-------- box
  #                  |---- BoxCtrl_div
  #                           |--------- transclude_div
  #
  # I'm not sure why, but that's how angular does ist. Therefore, we have to
  # apply a patch in order to be able to broadcast to the transclude and back.
  #
  # Therefore, the method `$scope.transclude_scope()` is added.
  # One can broadcast to the elements inside the box as follows:
  #
  #     $scope.transclude_scope().$broadcast( "myEvent", { my_argument: my_value } )
  #
  scope: true
  link: (scope, element, attrs)->
    scope.$watch( (->attrs.caption), (value)->
      scope.caption = attrs.caption
    )
  controller: [ "$scope", "$element", "$attrs", "$transclude", ($scope, $element, $attrs, $transclude)->

    # This method allows to access the transclude scope from the box controller:
    #
    #     scope_inside_the_box = $scope.transclude_scope()  # inside the BoxCtrl
    #
    $scope.transclude_scope = -> $scope.$$nextSibling

    # This will allow to access the box scope from the scope inside the box:
    #
    #     box_scope = $scope.box_scope()  # from inside the box (transclude).
    #
    $scope.$watch( (->$scope.$$nextSibling), (transclude_scope)->
      transclude_scope.box_scope = -> $scope
    )
  ]

} )

