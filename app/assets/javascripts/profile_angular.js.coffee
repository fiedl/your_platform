
app = angular.module( "Profile", [ "ngResource" ] )

# ProfileField Model
app.factory "ProfileField", ["$resource", ($resource) ->

  # these are temporary defined in the local scope of this block,
  # since we need them in the following initialization of the
  # ProfileField model.
#  profileable_id = $( "#profile" ).data( "profileable-id" )
#  profileable_type = $( "#profile" ).data( "profileable-type" )

  # Model initialization: Bind it to an AJAX resource.
  ProfileField = $resource(
    "/profile_fields/:id?profileable_id=:profileable_id&profileable_type=:profileable_type&parent_id=:parent_id",
    { id: "@id" },
    { update: { method: "PUT" } }
  )

  # Add further instance methods here:

  # This method will request the child profile fields of this profile field.
  # There is also a children attribute with pre-populated json data.
  # But the elements of the children array are no resource objects,
  # i.e. no JSON operations are possible on them.
  # Therefore, this getChildren() method is required, returning
  # an array of Resource objects of the child profile fields.
  #
  # Example:
  #     profile_fields = ProfileField.query( { profileable_type: "User", profileable_id: 2 } )
  #     parent_field = profile_fields[2]
  #     child_fields = parent_field.getChildren()   # Array of Resources
  #     child_fields = parent_field.children        # Array of Objects
  #
  ProfileField.prototype.getChildren = ->
    ProfileField.query( { parent_id: @id } )

  ProfileField.prototype.loadChildrenResource = ->
    this.children = this.getChildren() if this.children.length > 0

  # Add further class methods here.
  ProfileField.someClassMethod = (arg) ->
    console.log arg

  # The factory needs to return the model object.
  return ProfileField
]

# see: https://gist.github.com/Mithrandir0x/3639232
app.service( "Profileable", ->
  this.id = $( "#profile" ).data( "profileable-id" )
  this.type = $( "#profile" ).data( "profileable-type" )
  this.attributes = $( "#profile" ).data( "profileable" )
  this.title = this.attributes.title
)


@ProfileCtrl = ["$scope", "ProfileField", "Profileable", "$resource", ($scope, ProfileField, Profileable, $resource) ->

  $scope.editMode = false;

  # Load Data
  # ------------------------------------------------------------------------------------------

  # profileable, i.e. the object that has the profile fields
  $scope.profileable = Profileable

  # profile fields
  $scope.profile_fields = ProfileField.query( {
    profileable_type: $scope.profileable.type, profileable_id: $scope.profileable.id
  },
  -> # done loading, load the child profile fields:
    angular.forEach( $scope.profile_fields, (profile_field)->
      profile_field.loadChildrenResource()
    )
  )

  # FOR DEBUG:
  # TODO: DELETE THIS
  $.ProfileField = ProfileField
  $.scope = $scope
  # / FOR DEBUG

  # Controller Actions
  # ------------------------------------------------------------------------------------------

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

@ProfileFieldCtrl = [ "$scope", ($scope) ->
  $scope.isChildField = true if $scope.profile_field.parent_id
]

@InPlaceEditCtrl = [ "$scope", ($scope) ->
  $scope.editorEnabled = $scope.editMode

  $scope.$on( 'editModeChange', ->
    $scope.edit() if $scope.editMode
    $scope.save() if not $scope.editMode
  )
  $scope.$on( 'clickOutside', ->
    $scope.save() if not $scope.editMode
  )
  $scope.edit = ->
    $scope.editorEnabled = true
  $scope.save = ->
    $scope.profile_field.$update()
    $scope.editorEnabled = false
]
