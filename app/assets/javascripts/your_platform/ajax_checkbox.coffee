# Clicking on ajax checkboxes submits their forms.
$(document).on 'change', '.ajax_check_box', ->
  $(this).closest('form').submit()
