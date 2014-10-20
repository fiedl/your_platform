ready = ->

  # This button is hidden by javascript, since it should be shown as a fallback if javascript
  # is not available.
  #
  $( "#site_tools .edit_button" ).hide()

  # Hide 'edit' buttons for boxes where no .editable element is included.
  #
  hide_edit_button_if_not_needed = (edit_button)->
    box = edit_button.closest('.box')
    edit_button.hide() if box.find('div.content').find('.editable,.show_only_in_edit_mode,.best_in_place').length == 0

  $( ".edit_button:visible" ).each( ->
    hide_edit_button_if_not_needed $(this)
  )

$(document).ready(ready)
$(document).on('page:load', ready)
