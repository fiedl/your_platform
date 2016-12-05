$(document).on 'click', "a:not(.has_popover)", ->
  if this.href? && this.href != ""
    link_host = this.href.split("/")[2]
    document_host = document.location.href.split("/")[2]
    unless link_host is document_host
      window.open @href
      false
