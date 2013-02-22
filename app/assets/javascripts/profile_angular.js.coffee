
app = angular.module( "Profile", [ "ngResource" ] )

app.factory "ProfileField", ["$resource", ($resource) ->
  $resource( "/profile_fields/:id?profileable_id=:profileable_id&profileable_type=:profileable_type", { id: "@id", profileable_id: 2, profileable_type: "User" }, { update: { method: "PUT" } } )
]

@ProfileCtrl = ["$scope", "ProfileField", ($scope, ProfileField) ->

  $scope.profile_fields = ProfileField.query()

  $scope.addProfileField = ->
    profile_field = ProfileField.save( $scope.new_profile_field )
    $scope.profile_fields.push( profile_field )
    $scope.new_profile_field = {}

  $scope.editLabel = (label) ->
    alert( label )

]

@InPlaceEditCtrl = ($scope) ->
  $scope.editorEnabled = false
  $scope.edit = ->
    $scope.editorEnabled = true
  $scope.save = ->
    $scope.profile_field.$update()
    $scope.editorEnabled = false

