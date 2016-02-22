# Process asynchronously added content.
#
$(document).ready ->
  jQuery.fn.process = ->
    
    this.apply_edit_mode()
    this.process_box_tools()
    this.process_comment_tools()
    this.process_mentions()
    
    App.attachments.process($(this))
    App.galleries.process($(this))
