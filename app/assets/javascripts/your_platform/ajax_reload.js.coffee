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
#     $('#box').ajax_reload {
#       url: ...,
#       selector: '#attachments', # or:
#       selectors: ['#attachments', '#inline-pictures'],
#       success: -> ...
#     }
#
$(document).ready ->
  jQuery.fn.ajax_reload = (options)->

    root_element = this
    selectors = options['selectors'] if options['selectors']
    selectors = [options['selector']] if options['selector']
    url = options['url']
    success_callback = options['success']

    $.ajax {
      type: 'GET',
      url: url,
      success: (result)->
        for selector in selectors
          target = root_element.find(selector).addBack(selector)
          result_content = $(result).find(selector).html()
          target.html(result_content)
          target.fadeIn()
          target.process()
        success_callback?.call
      }

