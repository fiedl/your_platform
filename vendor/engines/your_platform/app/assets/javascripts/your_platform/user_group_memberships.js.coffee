# This file handles the add_user_group_membership form on the groups#show view, 
# which is rendered in the partial user_group_memberships/_new.
#
# The things that happen *after* creation by javascript are handled by
# app/views/user_group_memberships/create.js.erb
#
ready = ->
  $(document).on('submit', 'form.new_user_group_membership', ->
    $('.add-user-button').button('loading')
  )
  
$(document).ready(ready)
$(document).on('page:load', ready)
