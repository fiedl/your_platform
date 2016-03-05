
ready = ->

  jQuery.fn.apply_show_only_in_edit_mode = ->

    # When edit mode is entered, on all included '.editable' elements the 'edit' event is triggered.
    # When edit mode is left, the events 'save' or 'cancel' are triggered.
    # For <span class="show_only_in_edit_mode"></span> tags, these events are rather simple:
    # Just show or hide these spans!

    this.on( 'edit', '.show_only_in_edit_mode', ->
      $( this ).show()
    )
    this.on( 'save cancel', '.show_only_in_edit_mode', ->
      $( this ).hide()
    )

    # And just the opposite for <span class="do_not_show_in_edit_mode"></span>.
    this.on( 'edit', '.do_not_show_in_edit_mode', ->
      $( this ).hide()
    )
    this.on( 'save cancel', '.do_not_show_in_edit_mode', ->
      $( this ).show()
    )

    # In order to receive these events, the .show_only_in_edit_mode elements have to be .editable as well.
    this.find( ".show_only_in_edit_mode,.do_not_show_in_edit_mode" ).addClass( "editable" )

    return this

  # Apply this to the whole document in the beginning.
  $( document ).apply_show_only_in_edit_mode()

$(document).ready(ready)