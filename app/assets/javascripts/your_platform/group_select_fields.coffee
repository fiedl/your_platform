$(document).ready ->
  App.process_group_id_fields()

App.process_group_id_fields = ->
  $('input.group_id').each ->
    if $(this).siblings('input.group_name_select').length == 0
      $(this).before("<input type=\"text\" class=\"group_name_select\" placeholder=\"#{I18n.t('search_group')}\">")
      $(this).after('<ul class="group_search_results"></ul>')
      $(this).addClass 'group_id_hidden'

$(document).on 'keydown', '.group_name_select', ->
  $(this).removeClass('success failure progress')

$(document).on 'keypress', '.group_name_select', (e)->
  $(this).closest('form').find('input[type="submit"]').hide()
  if e.keyCode == 13 # enter
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

        },
        failure: (result)->
          group_name_select.removeClass('progress')
              .removeClass('success').addClass('failure')
    return false


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