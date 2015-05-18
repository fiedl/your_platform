ready = ->
  
  # use it reverse in order to select the first field, not the last one.
  $('.best_in_place.show_always').get().reverse().each -> $(this).trigger('edit')
  
  # $('.best_in_place.click_does_not_trigger_edit')
  
$(document).ready(ready)

