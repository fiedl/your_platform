search_box_selector = '.compact-nav-search-input'

results = []

$(document).on 'keydown', search_box_selector, (event)->
  if event.keyCode == 9  # tab
    query = $(this).val()
    if query != ""
      perform_query(query)
      false  # do not focus away

$(document).on 'keyup', search_box_selector, (event)->
  search_box = $(this)
  
  if event.keyCode == 32  # space
    query = search_box.val().slice(0,-1)
    perform_query(query)
    
  if event.keyCode == 8  # backspace
    if search_box.val() == ""
      results.pop()
      $('.compact-nav-button:last').remove()
  
  if event.keyCode == 13  # return
    if search_box.val() == ""
      if results.last()
        navigate_to results.last().url
      else
        navigate_to "/"
    else
      params = {
        query: search_box.val(),
        search_base: results.last()
      }
      url = $('#compact-nav-search form').attr('action') + 
        "?" + $.param(params)
      Turbolinks.visit url

navigate_to = (url)->
  Turbolinks.visit url

perform_query = (query)->
  remove_query_from_input(query)
  url = $('#compact-nav-search form').attr('action') + ".json"
  $.ajax {
    url: url,
    data: {
      query: query,
      search_base: results.last()
    },
    success: (result)->
      if typeof(result.title) == "undefined"
        add_query_to_input(query)
      else
        results.push(result)
        add_result(result)
  }
  
add_query_to_input = (query)->
  $(search_box_selector).val (index, value)->
    query + " " + value

remove_query_from_input = (query)->
  $(search_box_selector).val (index, value)->
    value.replace(query + " ", "").replace(query, "")

add_result = (result)->
  $(search_box_selector).before(result.button_html)
  
resize_search_box = ->
  # search_box = $(search_box_selector)
  # search_box.css({
  #   "width": ($('#user-menu').position().left - search_box.position().left) * 0.8
  # })
  
$(document).ready ->
  resize_search_box()
  
  if results.count() == 0
    $('.compact-nav-button').each (index)->
      results.push($(this).data('search-base'))
  
  $('.compact-nav-search-form').on 'keypress', (e)->
    if e.keyCode == 13
      return false

  if $(search_box_selector).size() > 0
    $(search_box_selector).focus()