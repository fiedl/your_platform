ready = ->
  
  $(document).on 'keydown', '.box.first h1 input', (e)->
    text = $(this).val()
    if (e.keyCode == 13) and ($('body.users').size() == 0)
      $('.vertical_menu .active a').text(text)
      $('#breadcrumb li.last.crumb a').text(text)
      
  # $(document).on 'dblclick', '.box.first h1 input', (e)->
  #   e.stopPropagation() # does not work
  
$(document).ready(ready)
$(document).on('page:load', ready)
