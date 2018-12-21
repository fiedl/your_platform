$(document).ready ->
  App.process_page_id_fields()

App.process_page_id_fields = ->
  $('input.page_id').each ->
    if $(this).siblings('input.page_title_select').length == 0
      $(this).before("<input type=\"text\" class=\"page_title_select title_select\" placeholder=\"#{I18n.t('search_page')}\">")
      $(this).after('<ul class="search_results page_search_results"></ul>')
      $(this).addClass 'id_hidden'

$(document).on 'keypress', '.page_title_select', (e)->
  $(this).closest('form').find('input[type="submit"]').hide()
  has_selected_page = true if $(this).hasClass('success')
  $(this).removeClass('success failure progress')

  if e.keyCode == 13 # enter

    # The user wants to submit the form.
    if has_selected_page? && has_selected_page
      $(this).closest('form').submit()

    # The user wants to select an entry from the results.
    else if $('.search_results li.selected').length > 0
      $('.search_results li.selected a').click()

    # The user wants to submit a search.
    else
      page_title_select = $(this)
      query = page_title_select.val()
      if query.length > 3
        url = "/api/v1/search_pages/"
        data = {
          query: query,
          limit: 10
        }
        page_title_select.removeClass('success')
            .removeClass('failure').addClass('progress')
        $.ajax {
          type: 'GET',
          url: url,
          data: data,
          success: (pages)->
            page_title_select.removeClass('progress').removeClass('failure')
            page_title_select.siblings('ul.search_results').find('li').remove()
            for page in pages
              breadcrumbs_string = page.breadcrumb_titles.join(" > ")
              li = "<li><a href=\"#\" data-page-id=\"#{page.id}\">
                <div class='page_title'>#{page.title}</div>
                <div class='result_breadcrumbs'>#{breadcrumbs_string}</div>
              </a></li>"
              page_title_select.siblings('ul.search_results').append(li)
          error: (result)->
            page_title_select.removeClass('progress')
                .removeClass('success').addClass('failure')
        }
    return false

$(document).on 'keydown', '.page_title_select, .page_search_results', (e)->
  currently_selected_li = $('.search_results li.selected')
  $('.search_results li').removeClass('selected') unless e.keyCode == 13 # enter
  if e.keyCode == 38 # up arrow
    if currently_selected_li.length > 0
      currently_selected_li.prev('li').addClass('selected')
    else
      $('.search_results li:last').addClass('selected')
  else if e.keyCode == 40 # down arrow
    if currently_selected_li.length > 0
      currently_selected_li.next('li').addClass('selected')
    else
      $('.search_results li:first').addClass('selected')

$(document).on 'click', 'ul.page_search_results li a', ->
  a = $(this)
  page_id = a.data('page-id')
  page_title = a.find('.page_title').text()
  a.closest('form').find('input[type=submit]').show()
  ul = a.closest('ul')
  ul.find('li').remove()
  ul.siblings('.page_title_select').val(page_title).addClass('success')
  ul.siblings('.page_id').val(page_id)
  false
