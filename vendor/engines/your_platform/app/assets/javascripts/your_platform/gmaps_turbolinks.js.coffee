ready = ->
  
  if $('.gmaps4rails_map').length > 0
    $.getScript("http://maps.google.com/maps/api/js?v=3.9&sensor=false&client=&key=&libraries=geometry&language=&hl=&region=")
    .success(->
      $.ajax(
        dataType: "script",
        cache: true,
        url: "http://maps.gstatic.com/cat_js/intl/de_de/mapfiles/api-3/12/17/%7Bmain,geometry%7D.js"
      )
      .success(->
        Gmaps.loadMaps()
      )
    )
    
    #
    # This works, but fixes the google static server to de_de.
    # Have a look at:
    #   http://stackoverflow.com/questions/18775450/jquery-cross-domain-ajax-callback-when-executed
    #
    
$(document).ready(ready)
$(document).on('page:load', ready)
