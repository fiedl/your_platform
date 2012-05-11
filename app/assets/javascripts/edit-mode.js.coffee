
jQuery ->
  $( ".only-in-edit-mode" ).bind( "edit", ->
    $( this ).show()
  ).bind( "save cancel", ->
    $( this ).hide()
  )
