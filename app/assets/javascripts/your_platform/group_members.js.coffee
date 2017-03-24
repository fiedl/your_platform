$(document).ready ->
  $('.add_group_member_tools').hide()

$(document).on 'change keyup paste', '.add_group_members .user-select-input', ->
  if $(this).val() != ""
    $('.add_group_member_tools').show()
  else
    $('.add_group_member_tools').hide()
    
$(document).on 'submit', '.add_group_members form.new_membership', (event)->
  setTimeout ->
    name_field = $('.user-select-input.new-membership')
    name_field.val('')
    name_field.focus()
    $('.add_group_member_tools').hide()
  , 200
  $('.updating_member_list').removeClass('hidden').show('blind')
