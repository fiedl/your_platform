jQuery ->
  $.datepicker.setDefaults( $.datepicker.regional[ "de" ] )
  $.datepicker.setDefaults( { dateFormat: 'yy-mm-dd' } )
  # TODO: This has to be generalized, depending on the current locale.
  # Attention: The standard datepicker format won't work, since
  # rails has dropped support for the date format "21/06/2012".
  # see: http://stackoverflow.com/questions/5372464/ruby-1-87-vs-1-92-date-parse
  # http://jquery-ui.googlecode.com/svn/trunk/ui/i18n/

  #$( "input.hasDatepicker" ).live( "change", ->
  #  $( this ).datepicker( 'option', {
  #    onClose: ( dateText, inst ) ->
  #      alert( "replaced it" )
  #  } )
  #)
  #
  #$("input.hasDatepicker").live( "onClose", ( dateText, inst ) ->
  #  alert( "date conversion" )
  #  input_field = $( this )
  #  alert( input_field.value )
  #  input_field.value = $.datepicker.parseDate( "d.m.yy", input_field.value )
  #  alert( input_field.value )
  #)
