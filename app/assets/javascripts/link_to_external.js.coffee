$(document).ready ->
  $("a").click ->
    link_host = @href.split("/")[2]
    document_host = document.location.href.split("/")[2]
    unless link_host is document_host
      window.open @href
      false
