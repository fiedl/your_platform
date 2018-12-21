$(document).ready ->
  App.process_group_id_fields()

App.process_group_id_fields = ->
  $('input.group_id').each ->
    if $(this).siblings('input.group_name_select').length == 0
      $(this).before("<input type=\"text\" class=\"group_name_select\" placeholder=\"#{I18n.t('search_group')}\">")
      $(this).after('<ul class="group_search_results"></ul>')
      $(this).addClass 'group_id_hidden'

$(document).on 'keypress', '.group_name_select', (e)->
  $(this).closest('form').find('input[type="submit"]').hide()
  has_selected_group = true if $(this).hasClass('success')
  $(this).removeClass('success failure progress')

  if e.keyCode == 13 # enter

    # The user wants to submit the form.
    if has_selected_group? && has_selected_group
      $(this).closest('form').submit()

    # The user wants to select an entry from the results.
    else if $('.group_search_results li.selected').length > 0
      $('.group_search_results li.selected a').click()

    # The user wants to submit a search.
    else
      group_name_select = $(this)
      query = group_name_select.val()
      if query.length > 3
        url = "/api/v1/search_groups/"
        data = {
          query: query,
          limit: 10
        }
        group_name_select.removeClass('success')
            .removeClass('failure').addClass('progress')
        $.ajax {
          type: 'GET',
          url: url,
          data: data,
          success: (groups)->
            group_name_select.removeClass('progress').removeClass('failure')
            group_name_select.siblings('ul.group_search_results').find('li').remove()
            for group in groups
              breadcrumbs_string = group.breadcrumb_titles.join(" > ")
              li = "<li><a href=\"#\" data-group-id=\"#{group.id}\">
                <div class='group_name'>#{group.name}</div>
                <div class='result_breadcrumbs'>#{breadcrumbs_string}</div>
              </a></li>"
              group_name_select.siblings('ul.group_search_results').append(li)

          error: (result)->
            group_name_select.removeClass('progress')
                .removeClass('success').addClass('failure')
        }
    return false

$(document).on 'keydown', '.group_name_select, .group_search_results', (e)->
  currently_selected_li = $('.group_search_results li.selected')
  $('.group_search_results li').removeClass('selected') unless e.keyCode == 13 # enter
  if e.keyCode == 38 # up arrow
    if currently_selected_li.length > 0
      currently_selected_li.prev('li').addClass('selected')
    else
      $('.group_search_results li:last').addClass('selected')
  else if e.keyCode == 40 # down arrow
    if currently_selected_li.length > 0
      currently_selected_li.next('li').addClass('selected')
    else
      $('.group_search_results li:first').addClass('selected')


$(document).on 'click', 'ul.group_search_results li a', ->
  a = $(this)
  group_id = a.data('group-id')
  group_name = a.find('.group_name').text()
  a.closest('form').find('input[type=submit]').show()
  ul = a.closest('ul')
  ul.find('li').remove()
  ul.siblings('.group_name_select').val(group_name).addClass('success')
  ul.siblings('.group_id').val(group_id)
  false