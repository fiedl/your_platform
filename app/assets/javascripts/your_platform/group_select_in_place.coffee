$(document).on 'edit', '.group_select_in_place', ->
  container = $(this)
  container.html("<input type='text' class='group_id'>")
  App.process_group_id_fields()

$(document).on 'save', '.group_select_in_place', ->
  container = $(this)
  group_name = container.find('input.group_name_select').val()
  group_id = container.find('input.group_id').val()

  container.find('input.group_name_select').remove()

  if group_id
    url = container.data('url')
    object_key = container.data('object-key')
    attribute_key = container.data('group-id-attribute-key')

    data = {}
    data[object_key] = {}
    data[object_key][attribute_key] = group_id

    $.ajax {
      url: url,
      method: 'put',
      data: data,
      success: ->
        container.html(group_name)
        App.success(container)
      error: ->
        container.html("")
        container.addClass('failure')
    }
  else
    container.html(container.data('group-name'))