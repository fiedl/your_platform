$(document).ready ->
  
  $("a.short_delivery_report").each ->
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

  $("a.short_delivery_report").mouseenter ->
    $(this).popover('show')
    $(this).addClass('just-opened')
    link = $(this)
    setTimeout (-> link.removeClass('just-opened')), 100
  
  $("a.short_delivery_report").mouseleave ->
    # Prevent the popover from staying open when the mouse just passes over.
    $(this).popover('hide') if $(this).hasClass('just-opened')

  $('body').click ->
    $("a.short_delivery_report").popover('hide')
