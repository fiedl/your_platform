ready = ->
  
  # This responds to the click before best_in_place is triggered.
  # So, hyperlinks can be clicked without triggering best_in_place.
  # For editing the links, use edit_mode.
  # 
  $('.best_in_place * a').on('click', (e)->
    e.stopPropagation()
  )
  
$(document).ready(ready)
$(document).on('page:load', ready)
