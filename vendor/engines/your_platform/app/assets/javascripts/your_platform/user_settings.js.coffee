$(document).ready ->
  
  $('#user_incognito').change ->
    $.ajax({
      type: 'PUT',
      url: $(this).data('url'),
      data: {
        user: {
          incognito: $('#user_incognito').prop('checked')
        }
      }
    })
    
    if $('#user_incognito').prop('checked') == true
      $('.my_indicator').hide()
    else
      $('.my_indicator').show()
        