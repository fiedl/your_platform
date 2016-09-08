$(document).ready ->
  $('td.event_starts_at input').datetimepicker()

  $('.change_semester_ok_button').hide()

$('td.event_starts_at input, td.event_name input, td.event_location input').on 'focus', ->
  $('td.event_starts_at, td.event_name, td.event_location').css('width', '')
  $(this).closest('td').css('width', '45%')

$(document).on 'change', '.semester_calendar .semester select', ->
  $('.edit_table').html('')
  $(this).closest('form').trigger('submit.rails') # http://stackoverflow.com/a/15847260/2066546

$(document).on 'input', '.semester_calendar .edit_table input', ->
  $('.semester_calendar .semester select').prop('disabled', 'disabled')

$(document).on 'click', '.save_semester_calendar_button', ->
  $(this).replaceWith("Bitte warten ...")
  $('.semester_calendar .edit_table form').trigger('submit.rails')
  $('.semester_calendar input').prop('disabled', 'disabled')
  $('.semester_calendar select').prop('disabled', 'disabled')
  false

$(document).on 'click', '.semester_calendar .btn.destroy_semester_calendar_event', ->
  $(this).prev('input[type=hidden]').val('1')
  $(this).closest('tr').hide('drop')
  false