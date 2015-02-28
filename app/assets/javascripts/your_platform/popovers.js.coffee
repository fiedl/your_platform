ready = ->
  # $("a[rel=popover]").popover()
  
  $(".has_popover").popover({
    html: true,
    trigger: 'manual',  # handled below
    content: (->
      $(this).next('.popover_content').html()
    )
  })

  $('.has_popover').click (event) ->
    $(".has_popover").not(this).popover('hide')  # close all the other popovers
    $(this).popover('show')
    event.preventDefault()
    event.stopPropagation()
    return false

  $('body').on 'click', '.popover_content', ->
    #$('.popover_content').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    return false
  
  $('body').click ->
    $(".has_popover").not('.stay_open').popover('hide')
    
  $('body').on 'click', '.close_popover', ->
    $('.has_popover').popover('hide')
    
    
    event.preventDefault()
    event.stopPropagation()
    return false


$(document).ready(ready)

