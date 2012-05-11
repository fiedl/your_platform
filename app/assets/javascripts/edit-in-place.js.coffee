
jQuery ->
  $( ".best_in_place" ).best_in_place()
                       .addClass( "editable ")
                       .bind( "edit", ->
                         $( this ).trigger( "click" )
                       )
