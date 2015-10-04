ready = ->
  
  $('.new.post #message_text').autosize()
  
  refresh_number_of_recipients_display = ->
    $('span.member_count').text("…")
    valid_from = ""
    valid_from = $('input.valid_from').val() if $('input.valid_from:hidden').size() == 0 # date visible
    if (valid_from.length == 10) or (valid_from.length == 0)  # valid date or no date
      url = $('span.member_count').data('query-url')
      url += "?valid_from=" + valid_from if valid_from.length == 10
      $.ajax({
        type: 'GET',
        url: url,
        success: (r)->
          $('span.member_count').text(r.member_count)
        }
      )
  
  $('label.constrain_validity_range').click ->
    if $(this).find('input').prop('checked')
      $('ul.constrain_validity_range').removeClass('hidden').show()
    else
      $('ul.constrain_validity_range').hide()
    refresh_number_of_recipients_display()
  
  $('input#valid_from').keyup ->
    refresh_number_of_recipients_display()

  $('#test_message, #confirm_message').click (click_event)->
    btn = $(this)
    real_message = ($(this).attr('id') == 'confirm_message')
    if real_message
      $('p.buttons.right').text I18n.t 'sending_message'
    else
      btn.text I18n.t 'test_message_sent'
      setTimeout ->
        btn.text I18n.t 'resend_test_message_to_my_own_address'
      , 2000
    if $('label.constrain_validity_range input').prop('checked')
      recipients_count = $('span.member_count').text()
      valid_from = $('input.valid_from').val()
    $.ajax(
      type: 'POST',
      url: $(this).attr('href'),
      #contentType: false,
      #processData: false,
      #contentType: 'multipart/form-data',
      #dataType: 'json',
      data: {
        text: $('#message_text').val(),
        subject: $('input.subject').val(),
        recipients_count: recipients_count,
        valid_from: valid_from,
        notification: 'instantly',
        #attachment_attributes: {
        #  "0": {
        #    file: $('fieldset.attachments input')[0].files
        #  }
        #}
      },
      success: (r)->
        if real_message
          $('p.buttons.right').text(I18n.t( 'message_has_been_sent_to_n_recipients', {n: r.recipients_count}))
          Turbolinks.visit r.post_url
    )
    click_event.preventDefault()

      
$(document).ready(ready)

