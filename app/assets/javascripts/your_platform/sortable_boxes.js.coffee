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
    panelList.find('.box').each (index, elem)->
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
    connectWith: '.draggable_boxes',
    handle: '.box',
    update: ->
      save_box_configuration()
    cancel: '.currently_in_edit_mode *',
    placeholder: 'draggable-box-placeholder col col-sm-3 col-xs-12',
    tolerance: "pointer"
  }

  unless App.permitted_bootstrap_column_classes?
    App.permitted_bootstrap_column_classes = [
      'col-sm-12', 'col-sm-9', 'col-sm-6', 'col-sm-3'
    ]

  all_bootstrap_column_classes_joined = '
      col-sm-1 col-sm-2 col-sm-3 col-sm-4
      col-sm-5 col-sm-6 col-sm-7 col-sm-8
      col-sm-9 col-sm-10 col-sm-11 col-sm-12'

  $(element).find('.draggable_boxes .resizable_col').resizable {
    handles: "e",
    resize: (event, ui)->
      ui.size.height = ui.originalSize.height
    stop: (event, ui)->
      row_width = $(this).closest('.row').width()
      column_width = row_width / 12
      column = $(this)

      # Find the best column class by minimizing the
      # width deviation from the targetted resize width.
      #
      column.css 'width', ''
      best_width_deviation = 1
      desired_class = "col-sm-12"
      for column_class in App.permitted_bootstrap_column_classes
        column.removeClass(all_bootstrap_column_classes_joined)
            .addClass(column_class)
        width_deviation = Math.abs(ui.size.width - column.width()) / row_width
        if width_deviation < best_width_deviation
          best_width_deviation = width_deviation
          desired_class = column_class
      column.removeClass(all_bootstrap_column_classes_joined)
          .addClass(desired_class)

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
          col.removeClass all_bootstrap_column_classes_joined
          col.addClass configuration.class
          col.show('fade')

    if App.no_lightbox_for_large_boxes
      $(element).find('.col-sm-12 .galleria').addClass('deactivate-auto-lightbox deactivate-magnification-glass')

$(document).ready ->
  App.process_box_configuration($('body'))
