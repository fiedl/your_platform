# Process asynchronously added content.
#
$(document).ready ->
  jQuery.fn.process = ->

    this.apply_edit_mode()
    this.process_box_tools()
    this.process_comment_tools()
    this.process_mentions()
    this.process_post_delivery_report_tools()

    App.attachments.process($(this))
    App.galleries.process($(this))
    App.process_group_maps($(this))
    App.process_box_configuration($(this))
    App.process_public_events($(this))

    afterglow.init() if afterglow?

    App.code_highlighting.process($(this))

    this.trigger('process')