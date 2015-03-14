ready = ->
  
  if $('.address_labels_export_button.auto_trigger').size() > 0
    setTimeout ->
      $('.address_labels_export_button.auto_trigger').click()
    , 200
    
  $('.address_labels_export_button').click( (event)->
    $('ul.dropdown-menu.list_export').dropdown('toggle')
    
    $('.export_modal').remove()
    $('body').append($('li.export_address_labels').data('modal-body'))
    $('.export_modal').modal('show')
    
    $('.confirm_address_labels_pdf_export').click( ->
      btn = $(this)
      
      # # This won't download the file :(
      # 
      # $.ajax {
      #    url: btn.closest('form').attr('action'),
      #    success: ->
      #      $('.export_modal').modal('hide')
      # }
      # 
      # # Therefore:
      #
      setTimeout ->
        $('.export_modal').modal('hide')
      , 5000
            
      btn.hide()
      btn.after('<div class="alert alert-success" role="alert">Das PDF wird nun heruntergeladen.</div>')
    )

    event.preventDefault()
    return false
  )
  
$(document).ready(ready)
