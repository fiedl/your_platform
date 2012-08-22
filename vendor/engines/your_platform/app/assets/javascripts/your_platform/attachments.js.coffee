jQuery ->
  form_span_selector = ".attachments .add_attachment"
  $( form_span_selector ).hide()

  button_selector = ".attachments .add_button"
  $( button_selector ).click( (e) ->
    $( button_selector ).hide()
    $( form_span_selector ).show( "blind" )
    e.preventDefault()
  )
