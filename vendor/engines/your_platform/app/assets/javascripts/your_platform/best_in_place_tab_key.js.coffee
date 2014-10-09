# Editing a single best_in_place element, pressing tab should focus and edit the next best_in_place element.
#

ready = ->
  $(document).on('keydown', '.best_in_place * input, .best_in_place * textarea', (event)->
    if event.keyCode == 9  # tab
      if not $(this).closest(".edit_mode_group").hasClass("currently_in_edit_mode")
        this_element = $(this).closest(".best_in_place")
        if not event.shiftKey
          next_element = $($(".best_in_place")[$(".best_in_place").index( this_element ) + 1])
          
          next_element.click().focus()
        else
          prev_element = $($(".best_in_place")[$(".best_in_place").index( this_element ) - 1])
          prev_element.click().focus()
          
        event.preventDefault()
  )

  $(document).on('focus', 'input', (event) ->
    $(event.target).select()
  )

  $(document).on('focus', 'textarea', (event) ->
    $(event.target).select()
  )
$(document).on('ready page:load', ready)
