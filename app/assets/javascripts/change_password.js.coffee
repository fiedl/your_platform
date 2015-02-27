$(document).ready ->
  
  $(document).on 'change', 'input#user_account_agreement', ->
    if $('input#user_account_agreement').prop('checked') == true
      $('.thanks').removeClass('hidden').show()
    else
      $('.thanks').addClass('hidden')