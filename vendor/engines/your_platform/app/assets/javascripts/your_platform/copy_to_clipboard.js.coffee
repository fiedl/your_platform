ready = ->
  $(".copy-to-clipboard").click ->
    content = $(this).attr('title')
    window.prompt "Copy to clipboard: Ctrl+C or ⌘+C, Enter", content

$(document).ready(ready)
