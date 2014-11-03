ready = ->
  
  fix_textareas = ->
    $('textarea').each ->
      $(this).val($(this).val().replace(/^ {1,}/gm, ""))
      
  fix_textareas()
  
  $(document).on('focus', 'textarea', fix_textareas)

$(document).ready(ready)
$(document).on('page:load', ready)