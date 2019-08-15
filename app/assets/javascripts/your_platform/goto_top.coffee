$(document).on 'click', '#gotoTop', ->
  $goToTopEl = $('#gotoTop')
  $body = $('body')
  $window = $(window)

  elementScrollSpeed = $goToTopEl.attr('data-speed')
  elementScrollEasing = $goToTopEl.attr('data-easing')
  if !elementScrollSpeed
    elementScrollSpeed = 700
  if !elementScrollEasing
    elementScrollEasing = 'easeOutQuad'

  $('body,html').stop(true).animate { 'scrollTop': 0 }, Number(elementScrollSpeed), elementScrollEasing
  false

$(window).on 'scroll', ->
  $goToTopEl = $('#gotoTop')
  $body = $('body')
  $window = $(window)

  elementMobile = $goToTopEl.attr('data-mobile')
  elementOffset = $goToTopEl.attr('data-offset')
  if !elementOffset
    elementOffset = 450
  if elementMobile != 'true' and ($body.hasClass('device-sm') or $body.hasClass('device-xs'))
    return true
  if $window.scrollTop() > Number(elementOffset)
    $goToTopEl.fadeIn()
    $body.addClass 'gototop-active'
  else
    $goToTopEl.fadeOut()
    $body.removeClass 'gototop-active'
