$(document).ready ->

  # use it reverse in order to select the first field, not the last one.
  $('.best_in_place.show_always').get().reverse().each -> $(this).trigger('edit')

  # $('.best_in_place.click_does_not_trigger_edit')

$(document).on 'best_in_place:before-update', '.best_in_place', ->
  $(this).addClass 'saving'
  $(this).removeClass 'success error'

$(document).on 'ajax:success', '.best_in_place', ->
  $(this).removeClass 'saving'
  $(this).addClass 'success'
  $(this).effect 'highlight'

$(document).on 'ajax:error', '.best_in_place', (request, error)->
  console.log "best in place error"
  console.log error
  $(this).removeClass 'saving'
  $(this).addClass 'error'

# Clicking on ajax checkboxes submits their forms.
$(document).on 'change', '.ajax_check_box', ->
  $(this).closest('form').submit()