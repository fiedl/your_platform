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

  # This is using the jqeruy ui datepicker together with the
  # timepicker addon from http://trentrichardson.com/examples/timepicker/.
  # https://github.com/trentrichardson/jQuery-Timepicker-Addon
  #
  $.timepicker.setDefaults
    dateFormat: "D, dd.mm.yy,",
    timeFormat: "HH:mm",
    parse: 'loose',
    showHour: true,
    showMinute: true,
    showSecond: false,
    stepMinute: 15,
    hour: 20,
    minute: 15,
    timeInput: true

  $('#create_event').click (e)->
    $.ajax({
      type: 'POST',
      url: $(this).attr('href'),
      success: (created_event) ->
        Turbolinks.visit created_event.path
    })
    $(this).replaceWith("<div class='alert alert-success'>Erstelle neue Veranstaltung. Bitte warten.</div>")
    e.preventDefault()

  $('.destroy_event').click (e)->
    destroy_button = $(this)
    href = destroy_button.attr('href')
    redirect_path = destroy_button.data('redirect')
    $('.alert').hide('blind', 300)
    $('.box').hide 'explode', 300, ->
      destroy_button.replaceWith("<div class='alert alert-danger'><strong>Veranstaltung wird wieder gelöscht.</strong> Bitte warten.</div>")
      $.ajax({
        type: 'DELETE',
        url: href,
        success: (result) ->
          $('.alert-danger').replaceWith("<div class='alert alert-success'><strong>Veranstaltung wurde gelöscht.</strong> Weiterleitung zur Startseite ...</div>")
          Turbolinks.visit redirect_path
        failure: (result) ->
          alert('Es ist etwas schief gegangen. Bitte laden Sie die Seite neu.')
      })
    e.stopPropagation()
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
        $('.box.upload_image').removeClass('hidden').show()
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
        $('.box.upload_image').hide()
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

  # Deactivate webcal:// links for android and windows, since they don't support it, apparently.
  #
  user_os = navigator.userAgent.toLowerCase()
  if (user_os.indexOf("android") > -1) or (user_os.indexOf("windows") > -1)
    if $('#ics_abo').count > 0
      $('#ics_abo').attr('href', $('#ics_abo').attr('href').replace('webcal://', 'https://'))

  # Select the text field for the event title if it shows the default title.
  if $('.box.first * h1 .best_in_place').text() == "Bezeichnung der Veranstaltung hier eingeben"
    $('.box.first * h1 .best_in_place').trigger('click') # to edit it

$(document).ready(ready)

