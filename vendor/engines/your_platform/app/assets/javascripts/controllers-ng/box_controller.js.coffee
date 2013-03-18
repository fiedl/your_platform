#
# This is the angular js controller for the box directive.
# It, for example, takes track of the edit mode and whether the 'edit' button
# has to be shown.
#
# TODO:
# - die erste box braucht noch ein "first"-css-Attribut.
#

@app.controller( "BoxCtrl", ["$scope", ($scope)->

  # This variable takes track of whether there are editable elements
  # inside the box. If that is the case, the 'edit' button is shown.
  #
  $scope.editablesInside = false

  # Controllers of editable elements have to broadcast an 'inPlaceEditorInitiated' event
  # to the box controller as follows:
  #
  #     $scope.box_scope().$broadcast( 'inPlaceEditorInitiated' )
  #
  $scope.$on( 'inPlaceEditorInitiated', -> $scope.editablesInside = true )
  $scope.$on( 'editableElementInitiated', -> $scope.editablesInside = true )

  # A box may be in editMode, which means that all editable elements
  # within the box are set to their editing state, e.g. in place editable elements.
  #
  $scope.editMode = false

  # This method is called by the 'edit' button in order to toggle the edit mode.
  #
  $scope.toggleEditMode = ->
    $scope.editMode = not $scope.editMode
    $scope.transclude_scope().$broadcast( 'editModeChange', {newState: $scope.editMode} )

] )

