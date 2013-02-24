
app = angular.module( "Profile", [ "ngResource" ] )

app.factory "ProfileField", ["$resource", "$rootScope", ($resource, $rootScope) ->
  profileable_id = $( "#profile" ).data( "profileable-id" )
  profileable_type = $( "#profile" ).data( "profileable-type" )

  $resource(
    "/profile_fields/:id?profileable_id=:profileable_id&profileable_type=:profileable_type",
    { id: "@id", profileable_id: profileable_id ,profileable_type: profileable_type },
    { update: { method: "PUT" } }
  )
]

# see: https://gist.github.com/Mithrandir0x/3639232
app.service( "Profileable", ->
  this.id = $( "#profile" ).data( "profileable-id" )
  this.type = $( "#profile" ).data( "profileable-type" )
  this.attributes = $( "#profile" ).data( "profileable" )
  this.title = this.attributes.title
)


@ProfileCtrl = ["$scope", "ProfileField", "Profileable", ($scope, ProfileField, Profileable) ->

  $scope.editMode = false;

  $scope.profileable = {}
  $scope.profileable = Profileable

  $scope.profile_fields = ProfileField.query()

  angular.forEach( $scope.profile_fields, (i,profile_field)->
    angular.forEach( profile_field.children, (j,child_field)->
      $scope.profile_fields[i].children[j] = ProfileField.get( { id: child_field.id } )
    )
  )

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
#  $scope.editorJustEnabled = false
  $scope.$on( 'editModeChange', ->
    $scope.edit() if $scope.editMode
    $scope.save() if not $scope.editMode
  )
  $scope.$on( 'clickOutside', ->
    $scope.save() if not $scope.editMode
  )
  $scope.edit = ->
    $scope.editorEnabled = true
#    $scope.editorJustEnabled = true
#    setTimeout( ->
#      $scope.editorJustEnabled = false
#    , 200 )
  $scope.save = ->
#    return if $scope.editorJustEnabled # since this is a click outside
#    if $scope.profile_field.type == ''
#      $scope.profile_field.type = "ProfileFieldTypes::Custom" # warning! writing something bad here, will crash the dataset!
    $scope.profile_field.$update()
    $scope.editorEnabled = false
]
