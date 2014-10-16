ready = ->
  
  # If an in-place-edit field contains a link when rendered,
  # a click on the link should follow the link rather than trigger
  # editing.
  # 
  $('.best_in_place * a').on('click', (e)->
    e.stopPropagation()
  )
  $('.best_in_place').on('click', 'a', (e)->
    e.stopPropagation()
  )
  
  # Do not follow links, when editing the link in an input field.
  #
  $('a .best_in_place * input').on('click', (e)->
    e.stopPropagation()
    return false
  )
  $(document).on('click', 'a .best_in_place * input', (e)->
    e.stopPropagation()
    return false
  )
  
$(document).ready(ready)
$(document).on('page:load', ready)
