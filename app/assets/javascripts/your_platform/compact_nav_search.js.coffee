window.App = {} if typeof(App) == 'undefined'

class App.CompactNav
  
  search_box_selector: '.compact-nav-search-input'
  results:             []
  
  constructor: ->
    self = this  # since "this" is overridden by the event handler
    $(document).on 'keydown', @search_box_selector, (event)->
      self.tab_has_been_pressed() if event.keyCode == 9
    $(document).on 'keyup', @search_box_selector, (event)->
      self.space_has_been_pressed() if event.keyCode == 32
      self.backspace_has_been_pressed() if event.keyCode == 8
      self.return_has_been_pressed() if event.keyCode == 13
      
  tab_has_been_pressed: ->
    if @query_string() != ""
      @perform_query()
      return false  # do not focus away

  space_has_been_pressed: ->
    @perform_query()
    
  backspace_has_been_pressed: ->
    if @query_string() == ""
      @results.pop()
      $('.compact-nav-button:last').remove()
      
  return_has_been_pressed: ->
    if @query_string() == ""
      if @results.last()
        @navigate_to @results.last().url
      else
        @navigate_to "/"
    else
      @perform_search_for_multiple_results()
      
  perform_search_for_multiple_results: ->
    params = {
      query: @query_string(),
      search_base: @results.last()
    }
    @navigate_to (@search_url() + "?" + $.param(params))
  
  query_string: ->
    $.trim(@search_box().val())
  
  search_url: ->
    $('#compact-nav-search form').attr('action')
  
  search_box: ->
    $(@search_box_selector)    

  navigate_to: (url)->
    Turbolinks.visit url

  perform_query: ->
    self = this  # since "this" is overridden by the event handler
    query = @query_string()
    @remove_query_from_input(query)
    $.ajax {
      url: @search_url() + ".json",
      data: {
        query: query,
        search_base: @results.last()
      },
      success: (result)->
        if typeof(result.title) == "undefined"
          self.add_query_to_input(query)
        else
          self.results.push(result)
          self.add_result(result)
    }
  
  add_query_to_input: (query)->
    $(@search_box_selector).val (index, value)->
      query + " " + value

  remove_query_from_input: (query)->
    $(@search_box_selector).val (index, value)->
      value.replace(query + " ", "").replace(query, "")

  add_result: (result)->
    $(@search_box_selector).before(result.button_html)
  
  resize_search_box: ->
    # search_box = $(search_box_selector)
    # search_box.css({
    #   "width": ($('#user-menu').position().left - search_box.position().left) * 0.8
    # })
    
  focus_search_box: ->
    @search_box().focus() if @search_box().size() > 0
  

App.compact_nav = new App.CompactNav()

$(document).ready ->
  App.compact_nav.resize_search_box()

  # Import breadcrumbs: This is used when the site is visited
  # via a link to a specific page.
  if App.compact_nav.results.count() == 0
    $('.compact-nav-button').each (index)->
      App.compact_nav.results.push($(this).data('search-base'))
  
  # Suppress form submission via return key, since this is
  # handled manually.
  $('.compact-nav-search-form').on 'keypress', (e)->
    if e.keyCode == 13
      return false

  # Focus the compact nav search box.
  App.compact_nav.focus_search_box()
