jQuery ->
  selector = ".lb-next,.lb-prev,.lb-close"
  $( selector ).live( "mouseenter", ->
    $( selector ).attr( "href", "#" ) # otherwise click will open new tab
  )
