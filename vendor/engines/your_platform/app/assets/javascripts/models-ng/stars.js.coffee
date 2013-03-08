#
# This represents a collection of stars that can be injected into controllers in order to
# keep track of the current user's bookmarks, which may be displayed at several places
# on the page.
#

@app.factory( "stars", [ "Star", "$rootScope", (Star, $rootScope)->

  stars = []

  stars.add = (newStar)->
    stars.push( newStar ) if $.inArray( newStar, stars ) == -1
    $rootScope.$broadcast( "starsChange" )

  stars.addArray = (newStars)->
    stars.push.apply( stars, newStars )
    # see: http://stackoverflow.com/questions/4156101/

  stars.fill = (newStars)->
    stars.length = 0
    stars.addArray newStars

  stars.remove = (starToRemove)->
    stars.splice( stars.indexOf( starToRemove ), 1 )
    $rootScope.$broadcast( "starsChange" )

  stars.find_all_by_user_id = (user_id)->
    Star.query( user_id: user_id, (fetchedStars)->
      stars.fill( fetchedStars )
    )
    $rootScope.$broadcast( "starsChange" )

  return stars

] )
