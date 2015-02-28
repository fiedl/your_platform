#
# This represents the Bookmark model within the angular js framework.
# The user can star/unstar, i.e. create or destroy bookmarks
# for bookmarkable objects.
#

@app.factory "Bookmark", ["$resource", ($resource) ->

  # Model initialization: Bind it to a JSON resource.
  Bookmark = $resource(
    "/bookmarks/:id?bookmarkable_id=:bookmarkable_id&bookmarkable_type=:bookmarkable_type&user_id=:user_id",
    { id: "@id" },
    { update: { method: "PUT" } }
  )

  # Add further instance methods here:

#  Bookmark.prototype.unstar = ->
#    this.$remove
#
#  # Add further class methods here.
#  Bookmark.someClassMethod = (arg) ->
#    console.log arg

  # The factory needs to return the model object.
  return Bookmark
]

