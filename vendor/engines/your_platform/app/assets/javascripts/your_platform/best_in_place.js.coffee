ready = ->
  
  $('.best_in_place.show_always').trigger('edit')
  
  # $('.best_in_place.click_does_not_trigger_edit')
  
$(document).ready(ready)
$(document).on('page:load', ready)
