
# The <span class="edit_mode_group"></span> elements receive 'edit', 'save' and 'cancel' events,
# when the user clicks the corresponding buttons '.edit_button', '.save_button' or '.cancel_button'.
# The edit_mode_group has to pass these events down to the contained .editable elements.

$( document ).on( "edit", ".edit_mode_group", (e) ->

  unless $( this ).hasClass( "currently_in_edit_mode" )
    $( this ).addClass( "currently_in_edit_mode" )

    $( $( this ).find( ".editable" ).get().reverse() ).each ->
      $( this ).trigger( "edit" )

)

$( document ).on( "save", ".edit_mode_group", ->

  if $( this ).hasClass( "currently_in_edit_mode" )
    $( this ).removeClass( "currently_in_edit_mode" )

    edit_mode_group = $( this )
    button_effect( $( this ).find( ".save_button" ), ->
      edit_mode_group.find( ".editable" ).trigger( "save" )
    )

)

$( document ).on( "cancel", ".edit_mode_group", ->

  if $( this ).hasClass( "currently_in_edit_mode" )
    $( this ).removeClass( "currently_in_edit_mode" )

    edit_mode_group = $( this )
    cancel_button = $( this ).find( ".cancel_button" )
    
    # if there is a cancel button, animate it and then cancel all elements.
    if cancel_button.size() > 0  
      button_effect( cancel_button, ->
        edit_mode_group.find( ".editable" ).trigger( "cancel" )
      )
      
    # if no cancel button exists, just trigger each element's cancel event.
    else  
      edit_mode_group.find( ".editable" ).trigger( "cancel" )

)

button_effect = ( button, callback ) ->
  button.effect( "pulsate", { times: 2 }, "fast", callback )

