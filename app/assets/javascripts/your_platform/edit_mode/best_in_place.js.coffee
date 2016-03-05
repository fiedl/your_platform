ready = ->

  jQuery.fn.apply_best_in_place = ->
    this.best_in_place()
        .addClass( "editable ")
        .unbind("edit")
        .bind( "edit", (e) ->
          $( this ).data( 'bestInPlaceEditor' ).activate()
          $( this ).find( "*" ).unbind( 'blur' )
                               .unbind( 'click' )
                               .unbind( 'keyup' )
                               .unbind( 'submit' )
                               .bind( 'keyup', keyUpHandler )
          e.stopPropagation()
        )
        .unbind("cancel")
        .bind( "cancel", (e) ->
          $( this ).data( 'bestInPlaceEditor' ).abort()
          e.stopPropagation()
        )
        .unbind("save")
        .bind( "save", (e) ->
          $( this ).data( 'bestInPlaceEditor' ).update()
          e.stopPropagation()
        )
    return this

  $( ".best_in_place" ).apply_best_in_place()

  keyUpHandler = (event) ->
    if event.keyCode == 27
      $( this ).closest( ".edit_mode_group" ).trigger( "cancel" )
    if event.keyCode == 13
      unless $( event.target ).is( "textarea" )
        $( this ).closest( ".edit_mode_group" ).trigger( "save" )

$(document).ready(ready)