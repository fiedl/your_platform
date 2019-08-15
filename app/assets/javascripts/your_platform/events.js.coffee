poll_for_the_group_being_ready = (path)->
  $.get path, (result)->
    if result.group_id
      $('#content').prepend("<div class='alert alert-success'>#{I18n.t('event_has_been_added_to_group')}<a href='#{window.location.pathname}'>#{I18n.t('reload_event')}</a></div>")
    else
      setTimeout (-> poll_for_the_group_being_ready(path)), 5000

$(document).on 'click', '#create_event', (e)->
  $.ajax({
    type: 'POST',
    url: $(this).attr('href'),
    success: (created_event) ->
      setTimeout (-> poll_for_the_group_being_ready("#{created_event.path}.json")), 5000
      Turbolinks.visit created_event.path
  })
  $(this).replaceWith("<div class='alert alert-success'>#{I18n.t('creating_event_please_wait')}</div>")
  e.preventDefault()
  false

$(document).on 'click', '.destroy_event', (e)->
  destroy_button = $(this)
  href = destroy_button.attr('href')
  redirect_path = destroy_button.data('redirect')
  $('.alert').hide('blind', 300)
  $('.box').hide 'explode', 300, ->
    destroy_button.replaceWith("<div class='alert alert-danger'>#{I18n.t('event_is_being_destroyed_again')}</div>")
    $.ajax({
      type: 'DELETE',
      url: href,
      success: (result) ->
        $('.alert-danger').replaceWith("<div class='alert alert-success'>#{I18n.t('event_has_been_destroyed_redirecting_to_start_page')}</div>")
        Turbolinks.visit redirect_path
      error: (result) ->
        alert(I18n.t('something_went_wrong_please_reload'))
    })
  e.stopPropagation()
  e.preventDefault()
  false

$(document).on 'click', '#join_event', (e)->
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
  e.preventDefault()

$(document).on 'click', '#leave_event', (e)->
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
  e.preventDefault()

$(document).on 'click', '#toggle_invite', (e)->
  $(this).data('loading-text', $(this).text())
  $(this).button('loading')
  $('form#invite').removeClass('hidden')
  $('form#invite').show()
  e.preventDefault()

$(document).on 'click', '#test_invite, #confirm_invite', (e)->
  $.ajax(
    type: 'POST',
    url: $(this).attr('href'),
    data: {
      text: $('#invitation_text').val()
    }
  )
  e.preventDefault()

$(document).on 'click', '#test_invite', (e)->
  $(this).text(I18n.t('send_test_to_my_email_again'))

$(document).on 'click', '#confirm_invite', (e)->
  $('form#invite').hide()
  $('#toggle_invite').button('reset')
  $('#toggle_invite').data('loading-text', $('#toggle_invite').text().replace('einladen …', 'eingeladen.'))
  $('#toggle_invite').button('loading')
  $('#toggle_invite').attr('title', '')


$(document).ready ->

  # Hide edit buttons on the events#show page, since
  # the edit mode does not work properly with the datepicker, yet.
  #
  # The fields can be edited separately by clicking on them
  # (best_in_place).
  #
  $('body.events .box.first .edit_button').hide()
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

  # Select the text field for the event title if it shows the default title.
  if $('.box.first * h1 .best_in_place').text() == I18n.t('enter_name_of_event_here')
    $('.box.first * h1 .best_in_place').trigger('click') # to edit it

