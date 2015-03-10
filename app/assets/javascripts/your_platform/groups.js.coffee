# This file handles the add_user_group_membership form on the groups#show view, 
# which is rendered in the partial user_group_memberships/_new.
#
# The things that happen *after* creation by javascript are handled by
# app/views/user_group_memberships/create.js.erb
# 
$(document).ready ->

  if $('.address_labels_export_button.auto_trigger').size() > 0
    setTimeout ->
      $('.address_labels_export_button.auto_trigger').click()
    , 200
  
  $(document).on 'submit', 'form.new_user_group_membership', (event)->
    
    # close the box if no text is entered
    if $('#user_group_membership_user_title').val() == ""
      event.preventDefault()
      $('.box.section.members').trigger('save')

    # if text is entered, send the form and switch to 'loading'.
    else
      text_field = $('.user-select-input.new-membership')
      button = $('.add-user-button')
      
      text_field.val('')
      text_field.focus()
      
      $('.new_users_waiting').append('<i class="fa fa-user-plus"></i>')
  
  $(document).on('edit', '.box.section.members', (event) ->
    $('input#user_group_membership_user_title').focus()
  )
  
  $(document).on('keydown', 'input#user_group_membership_user_title', (event) ->
    if event.keyCode == 27  # escape
      $('.box.section.members').trigger('cancel')
  )



