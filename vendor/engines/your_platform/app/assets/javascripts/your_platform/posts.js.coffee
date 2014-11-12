ready = ->
  $('label.constrain_validity_range').click ->
    if $(this).find('input').prop('checked')
      $('ul.constrain_validity_range').removeClass('hidden').show()
    else
      $('ul.constrain_validity_range').hide()
      
  $('input.valid_from').keyup ->
    text = $('input.valid_from').val()
    if text.length == 10
      url = $('span.member_count').data('query-url') + "?valid_from=" + text
      $.ajax({
        type: 'GET',
        url: url,
        success: (r)->
          $('span.member_count').text(r.member_count)
        }
      )

  $('#test_message, #confirm_message').click (click_event)->
    real_message = ($(this).attr('id') == 'confirm_message')
    if real_message
      $('p.buttons.right').text("Nachricht wird gesendet …")
    if $('label.constrain_validity_range input').prop('checked')
      recipients_count = $('span.member_count').text()
      valid_from = $('input.valid_from').val()
    $.ajax(
      type: 'POST',
      url: $(this).attr('href'),
      data: {
        text: $('#message_text').val(),
        subject: $('input.subject').val(),
        recipients_count: recipients_count ,
        valid_from: valid_from
      },
      success: (r)->
        if real_message
          $('p.buttons.right').text("Nachricht wurde an " + r.recipients_count + " Emptfänger versandt.")
    )
    click_event.preventDefault()

      
$(document).ready(ready)

