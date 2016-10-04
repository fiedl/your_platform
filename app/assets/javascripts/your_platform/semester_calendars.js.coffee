$(document).ready ->
  $('td.event_starts_at input').datetimepicker()
  $('td.event_starts_at select').first().focus()

  $('.change_semester_ok_button').hide()

  if $('.replace_semester_calendar_pdf').size() > 0
    $('.semester_calendar_pdf #new_attachment').hide()

$(document).on 'focus', 'td.event_name input, td.event_location input', ->
  $('td.event_name, td.event_location').css('width', '')
  $(this).closest('td').css('width', '45%')

$(document).on 'change', '.semester_calendars .semester select', ->
  # This works for semester_calendars#edit as well as for #index.
  $('.edit_table').html('')
  $(this).closest('form').trigger('submit.rails') # http://stackoverflow.com/a/15847260/2066546
  $('.semester_calendars .semester select').prop('disabled', 'disabled')

$(document).on 'input', '.semester_calendar .edit_table input', ->
  $('.semester_calendar .semester select').prop('disabled', 'disabled')

$(document).on 'change', '.semester_calendar .edit_table select', ->
  $('.semester_calendar .semester select').prop('disabled', 'disabled')

$(document).on 'click', '.save_semester_calendar_button', ->
  $(this).replaceWith(I18n.t('please_wait') + "..")
  $('.semester_calendar .edit_table form').trigger('submit.rails')
  $('.semester_calendar input').prop('disabled', 'disabled')
  $('.semester_calendar select').prop('disabled', 'disabled')
  $('.semester_calendar .edit_table a').prop('disabled', 'disabled').addClass('disabled')
  $('.semester_calendar .edit_table').prepend('<div class="alert alert-success">' + I18n.t('please_wait_while_semester_calendar_is_saving') + '</div>')
  false

$(document).on 'click', '.semester_calendar .btn.destroy_semester_calendar_event', ->
  $(this).prev('input[type=hidden]').val('1')
  $(this).closest('tr').hide()
  false

$(document).on 'click', '.add_semester_calendar_event', ->
  # http://railscasts.com/episodes/196-nested-model-form-revised
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'), 'g')
  last_table_row = $('.semester_calendar .edit_table tr:visible').last()
  new_table_row = $(this).data('fields').replace(regexp, time)
  $('.semester_calendar .edit_table tbody').append new_table_row
  new_table_row = $('.semester_calendar .edit_table tr').last()
  new_table_row.find('td.event_starts_at input').datetimepicker()
  for i in [0..4]
    new_table_row.find('td.event_starts_at select:eq(' + i + ')').val(last_table_row.find('td.event_starts_at select:eq(' + i + ')').val())
  new_table_row.find('td.event_location input').val(last_table_row.find('td.event_location input').val())
  for i in [0..(last_table_row.find('input[type="checkbox"]').size() - 1)]
    new_table_row.find('input[type="checkbox"]:eq(' + i + ')').prop('checked', last_table_row.find('input[type="checkbox"]:eq(' + i + ')').prop('checked'))
  new_table_row.find('td.event_starts_at select').first().focus()
  false

$(document).on 'keydown', '.semester_calendar .edit_table tr:last td.event_location input', (e)->
  if e.keyCode == 9 # tab
    $('.add_semester_calendar_event').click()
    false

$(document).on 'click', '.replace_semester_calendar_pdf', ->
  $(this).hide()
  $('.semester_calendar_pdf #new_attachment').show()
  false

