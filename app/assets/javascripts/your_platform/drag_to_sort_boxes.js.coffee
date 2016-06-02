$(document).ready ->
  panelList = $('.draggable_boxes')

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
  box_configuration = $('.box_configuration').data('box-configuration')
  box_configuration_update_url = $('.box_configuration').data('page-url')

  save_box_configuration = ->
    box_configuration = []
    $('.panel', panelList).each (index, elem)->
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

  panelList.sortable {
    # Only make the .panel-heading child elements support dragging.
    # Omit this to make then entire <li>...</li> draggable.
    handle: '.panel-heading',
    update: ->
      save_box_configuration()
      App.adjust_box_heights()
  }

  $('.draggable_boxes .resizable_col').resizable {
    handles: "e",
    resize: (event, ui)->
      ui.size.height = ui.originalSize.height
    stop: (event, ui)->
      if ui.size.width < 300
        $(this).addClass('col-sm-3')
        $(this).removeClass('col-sm-6')
        $(this).removeClass('col-sm-9')
      if ui.size.width > 300 and ui.size.width < 600
        $(this).addClass('col-sm-6')
        $(this).removeClass('col-sm-3')
        $(this).removeClass('col-sm-9')
      if ui.size.width > 600
        $(this).addClass('col-sm-9')
        $(this).removeClass('col-sm-3')
        $(this).removeClass('col-sm-6')
      $(this).css 'width', ''
      save_box_configuration()
      App.adjust_box_heights()
  }

  $('.draggable_boxes .resizable_col .box').each ->
    $(this).append("<span class='resize_handle'></span>")

  # Loop through box configuration in reverse in order to have new
  # boxes appear at the end rather at the top.
  #
  if box_configuration
    i = Object.keys(box_configuration).length
    while i > 0
      i--
      configuration = box_configuration[i]
      box = $("##{configuration.id}.box")
      col = box.closest('.col, .resizable_col')
      row = box.closest('.row')
      row.prepend(col)
      col.removeClass "col-sm-3 col-sm-6 col-sm-9"
      col.addClass configuration.class
      col.show('fade')