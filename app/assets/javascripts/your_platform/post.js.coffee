$(document).ready ->
  $(document).process_post_delivery_report_tools()
  
$.fn.process_post_delivery_report_tools = ->
  $(this).find("a.short_delivery_report").each ->
    link = $(this)
    url = link.data('long-report-url')
    link.popover
      placement: 'bottom',
      title: I18n.t('sent_to'),
      html: true,
      trigger: 'manual',
      content: -> ajax = $.ajax({url: url, method: 'get', async: false}).responseText
    if link.data('show-delivery-report') == true
      setTimeout (-> link.popover('show')), 500

  $(this).find("a.short_delivery_report").mouseenter ->
    $(this).popover('show')
    $(this).addClass('just-opened')
    link = $(this)
    setTimeout (-> link.removeClass('just-opened')), 100
  
  $(this).find("a.short_delivery_report").mouseleave ->
    # Prevent the popover from staying open when the mouse just passes over.
    $(this).popover('hide') if $(this).hasClass('just-opened')

  $('body').click ->
    $("a.short_delivery_report").popover('hide')
