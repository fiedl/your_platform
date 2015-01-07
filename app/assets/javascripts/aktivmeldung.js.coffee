ready = ->

  mark_as_valid = (input) ->
    $(input).addClass("valid").removeClass("invalid")
    
  mark_as_invalid = (input) ->
    $(input).addClass("invalid").removeClass("valid")
  
  validate = (input) ->
    judge.validate(input, {
      valid: ->
        mark_as_valid(input)
        
        # Special Case: Empty Select Fields
        if $(input).val() == ""
          mark_as_invalid(input)
          
        if $('form.formtastic .invalid').size() == 0
          $('.aktivmeldung input[type=submit]').removeClass('btn-warning')
          $('#why_fields_are_required').removeClass('hidden').hide()
        
      invalid: ->
        mark_as_invalid(input)
    })
  
  # Erforderliche Felder am Anfang als invalid markieren, 
  # damit man sie auch ausfüllt.
  #
  $('form.formtastic .required').each ->
    $(this).addClass("invalid") if $(this).val() == ""
  
  # Validierung bei Veränderung oder Tastendruck.
  #
  selector = 'form.formtastic input.required, form.formtastic textarea.required, form.formtastic select.required'
  $(selector).keyup ->
    validate(this)
  $(selector).change ->
    validate(this)
   
  # Bei Klick des Bestätigen-Buttons zunächst prüfen, ob noch 
  # Fehler vorliegen.
  #
  $("form.formtastic").submit (e) ->
    confirm_button = $('.aktivmeldung input[type=submit]')
    if $('form.formtastic .invalid').size() > 0
      e.preventDefault()
      $('#why_fields_are_required').removeClass('hidden').show()
      confirm_button.addClass('btn-warning')
    else
      confirm_button.hide()
      $('.progress').removeClass('hidden').show()
      #$("form.formtastic").submit()
    
$(document).ready(ready)
