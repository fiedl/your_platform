jQuery ->

  # fix issue with new tabs
  close_selector = ".lb-next,.lb-prev,.lb-close"
  $( close_selector ).live( "mouseenter", ->
    $( close_selector ).attr( "href", "#" ) # otherwise click will open new tab
  )

  # fix newline in lightbox caption
  caption_selector = ".lb-caption"
  $( caption_selector ).appear( ->
    $( caption_selector ).html( $( caption_selector ).html().replace( "\n", "<br />" ) )
  )

  # remove span tag from title
  strip_html = ( string ) ->
    string.replace( /(<.*?>)/ig, "" )
  $( "div.pictures a" ).each( ->
    old_title = $( this ).attr( 'title' )
    new_title = strip_html( old_title )
    $( this ).find( "img" ).attr( 'title', new_title )
  )

  # activate best_in_place editing
  $( caption_selector ).live( "mouseenter", ->
    $( this ).find( ".best_in_place" ).best_in_place()
  )

  # prevent lightbox hotkeys when in in-place-editing mode
  $( ".form_in_place input" ).live( "keyup", (e) ->
    code = e.keyCode
    code = e.which unless code
    unless code == 13 or code == 27
      e.stopPropagation()
  )
