$(document).ready ->
  
  $(document).on 'change', 'input#user_account_agreement', ->
    if $('input#user_account_agreement').prop('checked') == true
      $('.thanks').removeClass('hidden').show()
    else
      $('.thanks').addClass('hidden')
      
  $(document).on 'mouseover', '.pro_tipp_trigger', ->
    $('.pro_tipp_trigger').css('opacity', '1.0')
    $('.pro_tipp_body').show('fade')