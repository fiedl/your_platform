$(document).ready ->

  # use it reverse in order to select the first field, not the last one.
  $('.best_in_place.show_always').get().reverse().each -> $(this).trigger('edit')

  # $('.best_in_place.click_does_not_trigger_edit')

$(document).on 'ajax:success', '.best_in_place', ->
  $(this).effect 'highlight'

# Clicking on ajax checkboxes submits their forms.
$(document).on 'change', '.ajax_check_box', ->
  $(this).closest('form').submit()