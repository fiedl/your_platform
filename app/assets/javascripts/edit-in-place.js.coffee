
jQuery ->
  $( ".best_in_place" ).best_in_place()
                       .addClass( "editable ")
                       .bind( "edit", ->
                         $( this ).data( 'bestInPlaceEditor' ).activate()
                         $( this ).find( "*" ).unbind( 'blur' )
                                              .unbind( 'click' )
                                              .unbind( 'keyup' )
                                              .unbind( 'submit' )
                       )
                       .bind( "cancel", ->
                         $( this ).data( 'bestInPlaceEditor' ).abort()
                       )
                       .bind( "save", ->
                         $( this ).data( 'bestInPlaceEditor' ).update()
                       )
