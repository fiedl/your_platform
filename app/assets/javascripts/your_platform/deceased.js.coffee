$(document).on 'click', '.deceased_trigger', (event)->
  trigger_link = $(this)
  dropdown = trigger_link.closest('.workflow_triggers').find('ul.dropdown-menu')
    
  dropdown.dropdown('toggle')
  
  $('.deceased_modal').remove()
  $('body').append trigger_link.data('modal-body')
  $('.deceased_modal').modal('show')
  
  event.stopPropagation()
  event.preventDefault()
  return false


$(document).on 'click', '.confirm_event_of_death', ->
  $('.deceased_modal').modal('hide')
