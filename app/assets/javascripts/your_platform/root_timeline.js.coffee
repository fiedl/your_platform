last_loaded_day = 0
is_loading = false
current_day_interval = 1

load_next_page = ->
  if last_loaded_day < 20000
    load_next_news_for_n_days(current_day_interval)
  else
    $('.scroll_to_load').hide()

load_next_news_for_n_days = (n)->
  unless is_loading
    is_loading = true
    last_loaded_day += n
    $.ajax {
      type: 'GET',
      url: '/news',
      data: {
        days_ago: last_loaded_day,
        days_num: n
      },
      success: (result)->
        is_loading = false
        if result.length > 0
          current_day_interval = 1
          $('.row.insert_loaded_content_here').show()
          new_elements = $(result).appendTo($('.row.insert_loaded_content_here'))
          new_elements
            .hide()
            .fadeIn()
            .process()
          add_read_more_links_to new_elements
        else
          current_day_interval = Math.pow(current_day_interval + 1, 1.2)
          load_next_page()
      failure: (result)->
        is_loading = false
    }

add_read_more_links_to = (html)->
  $(html).find('.box').each ->
    box = $(this)
    box.addClass 'news'
    if box.height() > 250
      box.append('<div class="panel-footer"><a href="#" class="read-on">' + I18n.t('read_on') + '</a></div>')
      box.addClass 'collapsed'

$(document).ready ->
  last_loaded_day = 0
  is_loading = false

  if $('.scroll-indicator').size() > 0

    # initial loading
    #
    if $('.news_entry').size() == 0
      for t in [500, 600, 700]
        setTimeout ->
          is_loading = false
          load_next_page()
        , t

    # loading on scroll
    #
    $(window).scroll ->
      if $(window).scrollTop() > $(document).height() - $(window).height() - 800
        if $('#filter_news_query').val() == "" or $('#filter_news_query').size() == 0
          load_next_page()

$(document).on 'click', '.scroll-indicator', ->
  load_next_page()

$(document).on 'mouseenter', '.timeline_entry.already_read', ->
  $(this).animate {
    opacity: 1
  }

$(document).on 'mouseleave', '.timeline_entry.already_read', ->
  $(this).animate {
    opacity: 0.2,
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

$(document).on 'click', '.news a.read-on', ->
  box = $(this).closest('.box')
  box.find('.panel-footer').remove()
  box.removeClass 'collapsed'
  false