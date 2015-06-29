last_loaded_day = 0
is_loading = false

load_next_page = ->
  unless is_loading
    is_loading = true
    last_loaded_day += 1
    $.ajax {
      type: 'GET',
      url: '/news',
      data: {
        days_ago: last_loaded_day
      },
      success: (result)->
        is_loading = false
        if result.length > 0
          $('.row.insert_loaded_content_here').show()
          $(result)
            .appendTo($('.row.insert_loaded_content_here'))
            .hide()
            .fadeIn()
            .process()
        else
          load_next_page()
      failure: (result)->
        is_loading = false
    }

$(document).ready ->
  last_loaded_day = 0
  is_loading = false

  if $('.scroll-indicator').size() > 0

    setTimeout ->
      load_next_page()
    , 1000

    $(window).scroll ->
      if $(window).scrollTop() > $(document).height() - $(window).height() - 300
        if $('#filter_news_query').val() == ""
          load_next_page()


$(document).on 'mouseenter', '.timeline_entry.already_read', ->
  $(this).css('height', 'auto').animate {
    opacity: 1
  }

$(document).on 'mouseleave', '.timeline_entry.already_read', ->
  $(this).animate {
    opacity: 0.2,
    height: '200px'
  }

$(document).on 'submit', '.filter_news form', (event)->
  $('.row.insert_loaded_content_here').fadeOut()
  last_loaded_day = 0

  if $('#filter_news_query').val() == ""
    $('.row.insert_loaded_content_here').html('')
    load_next_page()
  else
    $.ajax {
      type: 'GET',
      url: '/news',
      data: {
        query: $('#filter_news_query').val()
      },
      success: (result)->
        is_loading = false
        if result.length > 0
          $('.row.insert_loaded_content_here').html('').show()
          $(result)
            .appendTo($('.row.insert_loaded_content_here'))
            .hide()
            .fadeIn()
            .process()
        else
          load_next_page()
      failure: (result)->
        is_loading = false
    }

  event.preventDefault()
  false
