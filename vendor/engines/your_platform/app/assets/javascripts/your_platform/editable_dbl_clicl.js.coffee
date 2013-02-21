#
# Trigger 'edit' on editable elements when double-clicked.
# This is especially usefull, when the element is shown as hyperlink
# when not edited.
#
jQuery ->

  $( document ).on( "dblclick", ".editable", ->
    $( this ).trigger( "click" )
  )
#  $( ".editable a" ).off( "click" )

  dblclicked = false
  clicked = false
  link = ""
  $(".editable a").bind( "click", ->
    console.log "click"
    event.stopPropagation() # Otherwise this will trigger 'edit'.
    event.preventDefault()
    unless clicked
      link = $( this ).attr( "href" )
      setTimeout( ->
        console.log "callback"
        unless dblclicked
          console.log "forward"
          console.log link
          document.location = link
        dblclicked = false
        clicked = false
        link = ""
      , 200 )
    clicked = true


  ).bind( "dblclick", (event)->
    console.log "dblclick"
    dblclicked = true
  )
  # unfortunately, this does not work:
  #$( document ).on( "click", ".editable a", (event) ->
  #  event.stopPropagation()
  #)
