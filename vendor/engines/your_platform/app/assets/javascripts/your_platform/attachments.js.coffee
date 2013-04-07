ready = ->
  $('#new_attachment').fileupload
    dataType: "script"
    add: (e, data) ->
      file = data.files[0]
      data.context = $($.parseHTML(tmpl("template-upload", file)))
      # see https://github.com/blueimp/JavaScript-Templates/issues/19
      #$('table.attachments').append(data.context)
      $('span.add_attachment').prepend(data.context)
      data.context.find('.processing').hide()
      data.submit()
    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.bar').css('width', progress + '%')
        if progress > 99
          data.context.find('.processing').show()
    done: (e, data) ->
      console.log "upload done"
      data.context.remove()

  $(document).bind('dragover', (e) ->
    $('.attachment_global_drop_zone').show()
  )
  $('.attachment_global_drop_zone').bind('dragleave drop', (e) ->
    $('.attachment_global_drop_zone').hide()
  )
  $(document).bind('mouseout', (e) ->
    $('.attachment_global_drop_zone').hide()
  )

$(document).ready(ready)
$(document).on('page:load', ready)
