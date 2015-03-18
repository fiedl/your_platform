$(document).ready ->
  
  if $('.password_strength_container').size() > 0
    lib_path = $('.password_strength_container').data('lib-script-path')
    $.getScript(lib_path).done ->
      validate_checked_account_agreement = ->
        $('#user_account_agreement').prop('checked')
      PasswordStrength.watch(
        "#user_account_password", 
        "#user_account_password_confirmation", 
        validate_checked_account_agreement
      )
      
  $(document).on 'change', 'input#user_account_agreement', ->
    if $('input#user_account_agreement').prop('checked') == true
      $('.thanks').removeClass('hidden').show()
    else
      $('.thanks').addClass('hidden')
      
  $(document).on 'mouseover', '.pro_tipp_trigger', ->
    $('.pro_tipp_trigger').css('opacity', '1.0')
    $('.pro_tipp_body').show('fade')