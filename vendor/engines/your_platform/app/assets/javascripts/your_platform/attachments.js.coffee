ready = ->
  $('#new_attachment').fileupload
    dataType: "script"
    add: (e, data) ->
      file = data.files[0]
      data.context = $($.parseHTML(tmpl("template-upload", file)))
      # see https://github.com/blueimp/JavaScript-Templates/issues/19
      #$('table.attachments').append(data.context)
      $('span.add_attachment').first().prepend(data.context)
      data.context.find('.processing').hide()
      data.submit()
    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.bar').css('width', progress + '%')
        if progress > 99
          data.context.find('.processing').show()
          data.context.find('.bar').hide()
    done: (e, data) ->
      console.log "upload done"
      console.log data.context
      data.context.remove()

  $(document).bind('dragover', (e) ->
    $('.attachment_global_drop_zone').fadeIn()
  )
  $('.attachment_global_drop_zone').bind('drop dragleave', (e) ->
    $('.attachment_global_drop_zone').fadeOut()
  )
  $(document).bind('mouseout', (e) ->
    $('.attachment_global_drop_zone').fadeOut()
  )

$(document).ready(ready)
$(document).on('page:load', ready)
