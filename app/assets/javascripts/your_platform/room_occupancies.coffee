$(document).ready ->
  $('.new_room_occupancy .existing_user_select').hide()

$(document).on 'change', 'input[type=radio][name=occupancy_type]',  ->
  if (this.value == 'existing_user')
    $('.existing_user_select').show()
  else
    $('.existing_user_select').hide()

$(document).on 'submit', '.new_room_occupancy form', ->
  $(this).hide()
  $(this).after(I18n.t('please_wait'))