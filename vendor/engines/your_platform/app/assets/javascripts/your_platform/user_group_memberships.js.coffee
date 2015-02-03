# This file handles the add_user_group_membership form on the groups#show view, 
# which is rendered in the partial user_group_memberships/_new.
#
# The things that happen *after* creation by javascript are handled by
# app/views/user_group_memberships/create.js.erb
#
ready = ->
  $(document).on('submit', 'form.new_user_group_membership', (event)->
    
    # close the box if no text is entered
    if $('#user_group_membership_user_title').val() == ""
      event.preventDefault()
      $('.box.section.members').trigger('save')

    # if text is entered, send the form and switch to 'loading'.
    else
      $('.add-user-button').button('loading')
      $('input#user_group_membership_user_title').attr('disabled', 'disabled')
      
  )
  
  $(document).on('edit', '.box.section.members', (event) ->
    $('input#user_group_membership_user_title').focus()
  )
  
  $(document).on('keydown', 'input#user_group_membership_user_title', (event) ->
    if event.keyCode == 27  # escape
      $('.box.section.members').trigger('cancel')
  )
  
$(document).ready(ready)

