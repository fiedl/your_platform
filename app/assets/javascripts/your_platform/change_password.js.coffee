previous_password_present = ->
  if $('#user_account_current_password').count() == 0
    # When the user has accessed this page through a reset email
    # with token, there is no need to enter the previous password
    # and this field is missing.
    return true
  else
    $('#user_account_current_password').val()? && ($('#user_account_current_password').val().length > 3)

password_and_confirmation_match = ->
  if $('#password').val() == $('#user_account_password_confirmation').val()
    $('#user_account_password_confirmation').addClass('success')
    true
  else
    $('#user_account_password_confirmation').removeClass('success')
    false

demo_passwords = ->
  [
    "k4nn3!",
    "kneipe lustig knödel gelungen", #thin spaces
    "kneipe lustig knödel gelungen",
    "kneipelustigknödelgelungen",
    "p4ssw0rt!",
    "abend lustig bowle lecker",
    "abendlustigbowlelecker",
    "Tr0ub4dor&3",
    "correct horse battery staple",
    "correcthorsebatterystaple"
  ]

password_is_no_demo_password = ->
  if $('#password').val() in demo_passwords()
    $('#password').addClass('failure')
    $('.Password__strength-meter').hide()
    false
  else
    $('#password').removeClass('failure')
    $('.Password__strength-meter').show()
    true

password_score = ->
  parseInt($('.Password__strength-meter--fill').attr('data-score')) # `.data('score')` does not work.

password_is_strong_enough = ->
  password_score() > 2

account_aggreement_checked = ->
  $('#user_account_agreement').prop('checked') == true

check_requirements = ->
  if previous_password_present() && password_is_no_demo_password() && password_is_strong_enough() && password_and_confirmation_match() && account_aggreement_checked()
    $('.requirements_not_met_yet').hide()
    $('.submit_confirmation').show()
  else
    $('.requirements_not_met_yet').show()
    $('.submit_confirmation').hide()

$(document).ready ->
  check_requirements()

$(document).on 'change', 'input#user_account_agreement', ->
  check_requirements()
  if $('input#user_account_agreement').prop('checked') == true
    $('.thanks').removeClass('hidden').show()
  else
    $('.thanks').addClass('hidden')

$(document).on 'keyup change', '#user_account_password_confirmation, #password', ->
  check_requirements()

$(document).on 'mouseover', '.pro_tipp_trigger', ->
  $('.pro_tipp_trigger').css('opacity', '1.0')
  $('.pro_tipp_body').show('fade')
