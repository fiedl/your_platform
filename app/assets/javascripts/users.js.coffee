ready = ->
  $( "span#gender" ).hide()
  $( "select#user_add_to_group" ).change( ->
    selected_option = $( "select#user_add_to_group option:selected" ).text().toLowerCase()
    if ( selected_option.indexOf( "gäste" ) >= 0 ) and ( selected_option.indexOf( "keil" ) < 0 )
      $( "span#gender" ).show()
    else
      $( "span#gender" ).hide()
      $( "span#gender option[value='false']" ).attr( 'selected', true ) # male
  )

$(document).ready(ready)
$(document).on('page:load', ready)
