#
# This represents a collection of bookmarks that can be injected into controllers in order to
# keep track of the current user's bookmarks, which may be displayed at several places
# on the page.
#
# Please note, that file uses the extensions of make-js-more-like-ruby.js.coffee.
#

@app.factory( "current_user_bookmarks", [ "Bookmark", "$rootScope", (Bookmark, $rootScope)->

  bookmarks = []

  broadcastChange = ->
    $rootScope.$broadcast( "bookmarksChange" )

  bookmarks.add = (newBookmark)->
    bookmarks.push( newBookmark ) unless bookmarks.includes( newBookmark )
    broadcastChange()

  bookmarks.addArray = (newBookmarks)->
    bookmarks.pushArray newBookmarks

  bookmarks.fill = (newBookmarks)->
    bookmarks.clear()
    bookmarks.addArray newBookmarks

  bookmarks.remove = (starToRemove)->
    bookmarks.removeItem starToRemove
    broadcastChange()

  bookmarks.find_all_by_user_id = (user_id)->
    Bookmark.query( user_id: user_id, (fetchedBookmarks)->
      bookmarks.fill( fetchedBookmarks )
    )
    broadcastChange()

  return bookmarks

] )
