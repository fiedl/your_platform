ready = ->
  $('.address_labels_export_button').click( (event)->
    $('ul.dropdown-menu.list_export').dropdown('toggle')
    
    $('.export_modal').remove()
    $('body').append($('li.export_address_labels').data('modal-body'))
    $('.export_modal').modal('show')
    
    $('.confirm_address_labels_pdf_export').click( ->
      btn = $(this)
      
      btn.attr('data-loading-text', btn.text() + " ...")
      btn.button("loading")
    )

    event.preventDefault()
    return false
  )
  

$(document).ready(ready)
$(document).on('page:load', ready)
