
app = angular.module( "Profile", [ "ngResource" ] )

app.factory "ProfileField", ["$resource", ($resource) ->
#  console.log $scope.profileable.type
  $resource( "/profile_fields/:id?profileable_id=:profileable_id&profileable_type=:profileable_type", { id: "@id", profileable_id: 2, profileable_type: "User" }, { update: { method: "PUT" } } )
]

@ProfileCtrl = ["$scope", "ProfileField", ($scope, ProfileField) ->

  $scope.editMode = false;

  $scope.profile_fields = ProfileField.query()

  $scope.addProfileField = ->
    profile_field = ProfileField.save( $scope.new_profile_field )
    $scope.profile_fields.push( profile_field )
    $scope.new_profile_field = {}


  $scope.deleteProfileField = (profile_field) ->
    id_to_remove_from_list = profile_field.id
    profile_field.$remove( (removed_profile_field, responseHeader) ->
      index = $scope.profile_fields.indexOf( removed_profile_field )
      $scope.profile_fields.splice( index, 1 ) unless index == -1
    )

  $scope.toggleEditMode = ->
    $scope.editMode = not $scope.editMode
    $scope.$broadcast( 'editModeChange' )

]

@InPlaceEditCtrl = [ "$scope", ($scope) ->
  $scope.editorEnabled = $scope.editMode
  $scope.$on( 'editModeChange', ->
    $scope.edit() if $scope.editMode
    $scope.save() if not $scope.editMode
  )
  $scope.edit = ->
    $scope.editorEnabled = true
  $scope.save = ->
    $scope.profile_field.$update()
    $scope.editorEnabled = false
]
