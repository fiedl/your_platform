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
    
    selector = '.my_indicator, #recommended_navables, #recent_navables'
    if $('#user_incognito').prop('checked') == true
      $(selector).hide()
    else
      $(selector).show()
        