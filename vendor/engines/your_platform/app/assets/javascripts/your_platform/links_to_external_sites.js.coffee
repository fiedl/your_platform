ready = ->
  # This applies to all hyperlinks, except:
  # - links that open popovers
  #
  $("a:not(.has_popover)").click ->
    link_host = @href.split("/")[2]
    document_host = document.location.href.split("/")[2]
    unless link_host is document_host
      window.open @href
      false

$(document).ready(ready)
$(document).on('page:load', ready)