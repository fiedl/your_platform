#
# This represents the Star model, i.e. bookmarks, within the angular js framework.
# The user can star/unstar starrable objects.
#

# Star Model
@app.factory "Star", ["$resource", ($resource) ->

  # Model initialization: Bind it to a JSON resource.
  Star = $resource(
    "/stars/:id?starrable_id=:starrable_id&starrable_type=:starrable_type&user_id=:user_id",
    { id: "@id" },
    { update: { method: "PUT" } }
  )

  # Add further instance methods here:

  Star.prototype.unstar = ->
    this.$remove

  # Add further class methods here.
  Star.someClassMethod = (arg) ->
    console.log arg

  # The factory needs to return the model object.
  return Star
]

