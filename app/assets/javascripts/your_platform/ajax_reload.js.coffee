# This introduces a mechanism to reload a section via ajax.
#
# Requirements:
#   1. The resource has to be provided via an url.
#   2. The section has to be identified by a selector.
#
# For example, if the `#attachments` section needs to be reloaded,
# this mechanism can fetch the content.
#
#     resource_url = "/pages/123"
#     $('#attachments').ajax_reload(resource_url, '#attachments')
#
$(document).ready ->
  jQuery.fn.ajax_reload = (url, selector)->
    target = this
    target.fadeOut()
    $.ajax {
      type: 'GET',
      url: url,
      success: (result)->
        result_content = $(result).find(selector).html()
        target.html(result_content)
        target.fadeIn()
        target.process()
    }