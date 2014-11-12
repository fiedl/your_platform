ready = ->
  $('.deceased_trigger').click( (event)->
    $('.workflow_triggers ul.dropdown-menu').dropdown('toggle')
    
    $('.deceased_modal').remove()
    $('body').append($('.deceased_trigger').data('modal-body'))
    $('.deceased_modal').modal('show')
    
    $('.confirm_event_of_death').click( ->
      btn = $(this)
      
      btn.attr('data-loading-text', "Bitte warten ...")
      btn.button("loading")
    )

    event.stopPropagation()
    event.preventDefault()
    return false
  )
  

$(document).ready(ready)
