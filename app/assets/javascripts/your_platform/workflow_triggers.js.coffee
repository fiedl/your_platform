$.fn.process_workflow_triggers = ->
  #this.find('.workflow_trigger').on 'click', ->
  #  link = $(this)
  #  url = link.attr('href')
  #  
  #  box = link.closest('.box')
  #  button = box.find('.workflow_triggers .dropdown-toggle')
  #  
  #  button.data('loading-text', button.text() + " ...")
  #  button.button('loading')
  #  button.dropdown('toggle')
  #  
  #  $.ajax {
  #    type: 'PUT',
  #    url: url,
  #    success: ->
  #      corporate_vita_selector = 
  #        "#" + box.find('.corporate-vita-for-user').attr('id')
  #      user_id = $(corporate_vita_selector).data('user-id')
  #      vita_url = "/api/v1/users/#{user_id}/corporate_vita"
  #      $(corporate_vita_selector).ajax_reload(
  #        vita_url, corporate_vita_selector)
  #  }
  #  
  #  # prevent default link action:
  #  false

$(document).ready ->
  $(document).process_workflow_triggers()
