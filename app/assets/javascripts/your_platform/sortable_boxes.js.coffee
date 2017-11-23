App.process_box_configuration = (element)->
  panelList = $(element).find('.draggable_boxes').addBack('.draggable_boxes')

  # The box configuration is persisted in the database.
  #
  # Example configuration:
  #
  #     box_configuration = [
  #       {id: "corporations-map-box", class: "col-sm-6"},
  #       {id: "wohnen-box", class: "col-sm-3"},
  #       {id: "page-224-box", class: "col-sm-3"},
  #       {id: "page-228-box", class: "col-sm-6"},
  #       {id: "page-225-box", class: "col-sm-6"}
  #     ]
  #
  box_configuration = $(element).find('.box_configuration').addBack('.box_configuration').data('box-configuration')
  box_configuration_update_url = $(element).find('.box_configuration').addBack('.box_configuration').data('page-url')

  save_box_configuration = ->
    box_configuration = []
    panelList.find('.panel').each (index, elem)->
      box_configuration.push {
        id: $(elem).attr('id'),
        class: $(elem).closest('.col, .resizable_col').attr('class')
      }
    $.ajax {
      type: 'PUT',
      url: box_configuration_update_url,
      data: {
        page: {
          box_configuration: box_configuration
        }
      }
    }

  $(element).find('.draggable_boxes').sortable {
    # Only make the .panel-heading child elements support dragging.
    # Omit this to make then entire <li>...</li> draggable.
    connectWith: '.draggable_boxes',
    handle: '.box',
    update: ->
      save_box_configuration()
    cancel: '.currently_in_edit_mode *',
    placeholder: 'draggable-box-placeholder col col-sm-3 col-xs-12',
    tolerance: "pointer"
  }

  $(element).find('.draggable_boxes .resizable_col').resizable {
    handles: "e",
    resize: (event, ui)->
      ui.size.height = ui.originalSize.height
    stop: (event, ui)->
      row_width = $(this).closest('.row').width()
      column_width = row_width / 4
      if ui.size.width < column_width
        $(this).addClass('col-sm-3')
        $(this).removeClass('col-sm-6')
        $(this).removeClass('col-sm-9')
        $(this).removeClass('col-sm-12')
      if ui.size.width > column_width and ui.size.width < column_width * 2
        $(this).addClass('col-sm-6')
        $(this).removeClass('col-sm-3')
        $(this).removeClass('col-sm-9')
        $(this).removeClass('col-sm-12')
      if ui.size.width > column_width * 2 and ui.size.width < column_width * 3
        $(this).addClass('col-sm-9')
        $(this).removeClass('col-sm-3')
        $(this).removeClass('col-sm-6')
        $(this).removeClass('col-sm-12')
      if ui.size.width > column_width * 3
        $(this).addClass('col-sm-12')
        $(this).removeClass('col-sm-3')
        $(this).removeClass('col-sm-6')
        $(this).removeClass('col-sm-9')
      $(this).css 'width', ''
      save_box_configuration()
  }

  $(element).find('.draggable_boxes .resizable_col .box').each ->
    $(this).append("<span class='resize_handle'></span>")

  # Loop through box configuration in reverse in order to have new
  # boxes appear at the end rather at the top.
  #
  if box_configuration
    i = Object.keys(box_configuration).length
    while i > 0
      i--
      configuration = box_configuration[i]
      if configuration.id
        box = $("##{configuration.id}.box")
        col = box.closest('.col, .resizable_col')
        row = box.closest('.row')
        if box.count() > 1
          col.last().remove()
        else
          row.prepend(col)
          col.removeClass "col-sm-3 col-sm-6 col-sm-9 col-sm-12"
          col.addClass configuration.class
          col.show('fade')

$(document).ready ->
  App.process_box_configuration($('body'))
