# Process asynchronously added content.
#
$(document).ready ->
  jQuery.fn.process = ->
    
    this.apply_edit_mode()
    
    this.find('.box.event .edit_button').hide()
    this.find('.box.event #ics_export').hide()
    
    App.attachments.process($(this))
    App.galleries.process($(this))
