
ready = ->

  $( ".box" ).bind( "toggle-minimized", ->
    $(this).find( ".content" ).toggle( "blind" )
    clear_selection()
  )

  $( ".box .minimize" ).click( ->
    $(this).closest( ".box" ).trigger( "toggle-minimized" )
  )

  $( ".box .head" ).dblclick( (event) ->
    $(this).closest( ".box" ).trigger( "toggle-minimized" )
  )

  clear_selection = ->
    if (window.getSelection)
      if (window.getSelection().empty) # Chrome
        window.getSelection().empty()
      else if (window.getSelection().removeAllRanges) # Firefox
        window.getSelection().removeAllRanges()
      else if (document.selection) # IE
        document.selection.empty()

$(document).ready(ready)
