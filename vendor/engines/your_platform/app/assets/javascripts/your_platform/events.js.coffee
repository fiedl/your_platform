ready = ->
  
  # Hide edit buttons on the events#show page, since
  # the edit mode does not work properly with the datepicker, yet.
  #
  # The fields can be edited separately by clicking on them
  # (best_in_place).
  #
  $('body.events * .edit_button').hide()
  
  #$('body.events * .start_at * input').lock()
  
  $.timepicker.setDefaults
    dateFormat: "DD, dd. MM yy,",
    timeFormat: "HH:mm 'Uhr'",
    parse: 'loose'
    showSecond: false,
    stepMinute: 5,
    hour: 20,
    minute: 15
    
  $('#join_event').click (event)->
    btn = $(this)
    $.ajax({
      type: 'POST',
      url: btn.attr('href'),
      success: (r) -> 
        btn.button('reset')
        btn.hide()
        $('#leave_event').show()
        $('#attendees_avatars').html(r.attendees_avatars)
      }
    )
    btn.data('loading-text', btn.text() + " ...")
    btn.button('loading')
    event.preventDefault()

  $('#leave_event').click (event)->
    btn = $(this)
    $.ajax({
      type: 'DELETE',
      url: btn.attr('href'),
      success: (r)->
        btn.button('reset')
        btn.hide()
        $('#join_event').show()
        $('#attendees_avatars').html(r.attendees_avatars)
      }
    )
    btn.data('loading-text', btn.text() + " ...")
    btn.button('loading')
    event.preventDefault()

$(document).ready(ready)
$(document).on('page:load', ready)
