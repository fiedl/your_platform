ready = ->
  
  # Hide edit buttons on the events#show page, since
  # the edit mode does not work properly with the datepicker, yet.
  #
  # The fields can be edited separately by clicking on them
  # (best_in_place).
  #
  $('body.events * .edit_button').hide()
  $('.box.upcoming_events * .edit_button').hide()
  
  #$('body.events * .start_at * input').lock()
  
  $.timepicker.setDefaults
    dateFormat: "DD, dd. MM yy,",
    timeFormat: "HH:mm 'Uhr'",
    parse: 'loose'
    showSecond: false,
    stepMinute: 5,
    hour: 20,
    minute: 15
    
  $('#create_event').click (e)->
    $.ajax({
      type: 'POST',
      url: $(this).attr('href'),
      success: (created_event) ->
        $(this).button('reset')
        $(this).data('loading-text', 'Veranstaltung wurde erstellt. Einen Moment noch, bitte.')
        $(this).button('loading')
        window.location = created_event.path
    })
    $(this).data('loading-text', $(this).text() + " ...")
    $(this).button('loading')
    e.preventDefault()
    
  $('#join_event').click (event)->
    btn = $(this)
    $.ajax({
      type: 'POST',
      url: btn.attr('href'),
      success: (r) -> 
        btn.button('reset')
        btn.hide()
        $('#leave_event').removeClass 'hidden'
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
        $('#join_event').removeClass 'hidden'
        $('#join_event').show()
        $('#attendees_avatars').html(r.attendees_avatars)
      }
    )
    btn.data('loading-text', btn.text() + " ...")
    btn.button('loading')
    event.preventDefault()
    
  $('#toggle_invite').click (click_event)->
    $(this).data('loading-text', $(this).text())
    $(this).button('loading')
    $('form#invite').removeClass('hidden')
    $('form#invite').show()
    click_event.preventDefault()
    
  $('#test_invite, #confirm_invite').click (click_event)->
    $.ajax(
      type: 'POST',
      url: $(this).attr('href'),
      data: {
        text: $('#invitation_text').val()
      }
    )
    click_event.preventDefault()

  $('#test_invite').click (e)->
    $(this).text('Erneut zum Testen an meine eigene Adresse senden.')

  $('#confirm_invite').click (click_event)->
    $('form#invite').hide()
    $('#toggle_invite').button('reset')
    $('#toggle_invite').data('loading-text', $('#toggle_invite').text().replace('einladen …', 'eingeladen.'))
    $('#toggle_invite').button('loading')
    $('#toggle_invite').attr('title', '')
    
  if $('.box.first * h1 .best_in_place').text() == "Bezeichnung der Veranstaltung hier eingeben"
    $('.box.first * h1 .best_in_place').trigger('click') # to edit it

$(document).ready(ready)
$(document).on('page:load', ready)
