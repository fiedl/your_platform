ready = ->
  # $("a[rel=popover]").popover()
  $(".has_popover").popover({
    html: true
    #container: $(this),
    content: (->
      $(this).next('.popover_content').html()
    )
  })
  
  $(".has_popover").click( (e)->
    e.preventDefault()
    e.stopPropagation()
  )

  $(".popover_content").click( (e)->
    e.preventDefault()
    e.stopPropagation()
  )
  
  $('body').click(->
    $(".has_popover").popover('hide')
  )

$(document).ready(ready)
$(document).on('page:load', ready)
