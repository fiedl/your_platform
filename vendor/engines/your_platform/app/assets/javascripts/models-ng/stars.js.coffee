#
# This represents a collection of stars that can be injected into controllers in order to
# keep track of the current user's bookmarks, which may be displayed at several places
# on the page.
#
# Please note, that file uses the extensions of make-js-more-like-ruby.js.coffee.
#

@app.factory( "stars", [ "Star", "$rootScope", (Star, $rootScope)->

  stars = []

  broadcastChange = ->
    $rootScope.$broadcast( "starsChange" )

  stars.add = (newStar)->
    stars.push( newStar ) unless stars.includes( newStar )
    broadcastChange()

  stars.addArray = (newStars)->
    stars.pushArray newStars

  stars.fill = (newStars)->
    stars.clear()
    stars.addArray newStars

  stars.remove = (starToRemove)->
    stars.removeItem starToRemove
    broadcastChange()

  stars.find_all_by_user_id = (user_id)->
    Star.query( user_id: user_id, (fetchedStars)->
      stars.fill( fetchedStars )
    )
    broadcastChange()

  return stars

] )
