$(document).ready ->
  
  show_quick_result = (title, body)->
    $('#header_search input#query').popover('destroy')
    $('#header_search input#query').popover({
      title: title,
      content: body,
      html: true,
      animation: false,
      placement: 'left'
    })
    $('#header_search input#query').popover('show')
    $('div.popover.left').css('left', parseInt($('div.popover.left').css('left')) - 40)
  
  $(document).on 'keyup', '#header_search input#query', ->
    query = $(this).val()
    $.ajax({
      type: 'GET',
      data: {
        query: query
      },
      url: $(this).data('preview-url'),
      success: (result) ->
        if typeof(result) != 'undefined'
          show_quick_result(result.title, result.body)
    })