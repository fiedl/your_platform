tmp = $.fn.popover.Constructor::show

$.fn.popover.Constructor::show = ->
  tmp.call this
  if @options.callback
    @options.callback()
  return

$(document).ready ->

  help_button_popover_body = $('#help_button_popover_body').html()
  $('#help_button_popover_body').remove()

  selector = '.help-button'
  $(selector).off 'click'
  $(selector).on 'click', -> false
  $(selector).popover({
    title: $('#help_button_title').html(),
    content: "<div class='help-button-temp'></div>",
    placement: 'bottom',
    trigger: 'click',
    html: true,
    animation: false,
    callback: ->
      $('.help-button-temp').html(help_button_popover_body)
  })


$(document).on 'click', '.close_help_popover', ->
  $('.help-button').popover('hide')

$(document).on 'submit', '#help_form', ->
  form = $(this)
  success_message = $(this).parent().find('.success')
  form.hide('blind')
  success_message.removeClass('hidden').show('blind')
  $.ajax {
    url: form.attr('action'),
    method: 'post',
    data: {
      text: form.find('textarea').val(),
      browser: $.pgwBrowser().browser,
      os: $.pgwBrowser().os,
      viewport: $.pgwBrowser().viewport,
      location: window.location.href,
      navable: $('body').data('navable')
    }
  }
  false
