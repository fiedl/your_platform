ready = ->
  
  $('.best_in_place.show_always').trigger('edit')
  
$(document).ready(ready)
$(document).on('page:load', ready)
