ready = ->
  
  $(document).on 'keydown', '.box.first h1 input', (e)->
    if (e.keyCode == 13)
      setTimeout ->
        # Use `setTimeout`. Otherwise, the `text()` does not contain
        # the content of the input field.
        text = $('.box.first h1').text()
        $('.vertical_menu .active a').text(text)
        $('#breadcrumb li.last.crumb a').text(text)
      , 100
      
  # $(document).on 'dblclick', '.box.first h1 input', (e)->
  #   e.stopPropagation() # does not work
  
$(document).ready(ready)

