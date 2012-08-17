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

  # create best in place tags for in-place editing of title and description
  $( caption_selector ).live( "mouseenter", ->

  )
