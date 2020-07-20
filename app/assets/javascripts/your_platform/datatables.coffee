App.datatables = {
  language_options: ->
    if $('body').data('locale') == 'de'
      {
        "sEmptyTable":     "Keine Daten in der Tabelle vorhanden.",
        "sInfo":           "_START_ bis _END_ von _TOTAL_ Einträgen",
        "sInfoEmpty":      "0 bis 0 von 0 Einträgen",
        "sInfoFiltered":   "(gefiltert von insgesamt _MAX_ Einträgen)",
        "sInfoPostFix":    "",
        "sInfoThousands":    ".",
        "sLengthMenu":     "_MENU_ Einträge anzeigen",
        "sLoadingRecords":   "Wird geladen ...",
        "sProcessing":     "Bitte warten ...",
        "sSearch":         "",
        "sZeroRecords":    "Keine Einträge vorhanden.",
        "oPaginate": {
          "sFirst":      "",
          "sPrevious":   "Zurück",
          "sNext":       "Weiter",
          "sLast":       ""
        },
        "oAria": {
          "sSortAscending":  ": aktivieren, um Spalte aufsteigend zu sortieren",
          "sSortDescending": ": aktivieren, um Spalte absteigend zu sortieren"
        }
      }
    else
      {}

  common_configuration: ->
    {
      "destroy": true, # if the table already exists
      "sDom":"t<'card-footer d-flex align-items-center'<'m-0 text-muted' i><'pagination m-0 ml-auto'p>>",
      "sPaginationType": "full", # https://datatables.net/reference/option/pagingType
      "bJQueryUI": true,
      "lengthMenu": [ 10, 20, 50, 100, 1000 ],
      "language": App.datatables.language_options(),
      "fixedHeader": true,
      "drawCallback": (settings)->
        # Hide the pagination elements if there is only one page.
        if (settings._iDisplayLength > settings.fnRecordsDisplay())
          $(settings.nTableWrapper).find('.dataTables_paginate').hide()
        else
          $(settings.nTableWrapper).find('.dataTables_paginate').show()
        $('.dataTables_wrapper .paginate_button').addClass('btn btn-outline-secondary')
        $('.dataTables_paginate').addClass('btn-group btn-group-sm')
      "hideEmptyCols": true
    }

  extend_sort: ->
    # Sorting by date in German:
    # http://datatables.net/plug-ins/sorting/date-de
    #
    jQuery.extend jQuery.fn.dataTableExt.oSort,
      "de_date-asc": (a, b) ->
        x = undefined
        y = undefined
        if $.trim(a) isnt ""
          deDatea = $.trim(a).split(" ")
          deDatea2 = deDatea[0].split(".")
          x = (deDatea2[2] + deDatea2[1] + deDatea2[0]) * 1
        else
          x = Infinity # = l'an 1000 ...
        if $.trim(b) isnt ""
          deDateb = $.trim(b).split(" ")
          deDateb = deDateb[0].split(".")
          y = (deDateb[2] + deDateb[1] + deDateb[0]) * 1
        else
          y = Infinity
        z = ((if (x < y) then -1 else ((if (x > y) then 1 else 0))))
        z

      "de_date-desc": (a, b) ->
        x = undefined
        y = undefined
        if $.trim(a) isnt ""
          deDatea = $.trim(a).split(" ")
          deDatea2 = deDatea[0].split(".")
          x = (deDatea2[2] + deDatea2[1] + deDatea2[0]) * 1
        else
          x = Infinity
        if $.trim(b) isnt ""
          deDateb = $.trim(b).split(" ")
          deDateb = deDateb[0].split(".")
          y = (deDateb[2] + deDateb[1] + deDateb[0]) * 1
        else
          y = Infinity
        z = ((if (x < y) then 1 else ((if (x > y) then -1 else 0))))
        z

  create: (selector, options)->
    if $(selector).count() > 0
      if $.fn.dataTable.isDataTable(selector)
        $(selector).find(".dataTables_empty").closest("tr").remove()
        $(selector).empty()
        $(selector).dataTable().fnDestroy()

      #  #if $(selector).parents('.dataTables_wrapper').count() == 0
      configuration = {}
      $.extend configuration, App.datatables.common_configuration()
      $.extend configuration, options
      $(selector).dataTable(configuration)
}

$(document).on 'dblclick', '.datatable tbody tr', ->
  $(this).find('a')[0].click() if $(this).find('a').count() > 0

App.datatables.init = ->

  App.datatables.create '.datatable.activities', {
    "pageLength": 100,
    "order": [[0, "desc"]],
    "columnDefs": [
      {width: "50%", targets: 4}
    ]
  }

  App.datatables.create '.datatable.groups', {
    "order": [[0, "asc"]],
    "pageLength": 100
  }

  App.datatables.create '.datatable.group_of_groups', {
    "pageLength": 100
  }

  App.datatables.create '.datatable.events', {
    "order": [[1, "desc"]],
    "pageLength": 100,
    columnDefs: [
      { type: 'de_date', targets: 1}
    ]
  }

  App.datatables.create '.datatable.statistics', {
    "pageLength": 100,
    "order": [[0, "asc"]]
  }

  num_of_memberships_cols = $('.datatable.memberships thead td').count()
  App.datatables.create '.datatable.memberships', {
    "pageLength": 100,
    columnDefs: [
      { type: 'de_date', targets: num_of_memberships_cols - 1 },
      { type: 'de_date', targets: num_of_memberships_cols }
    ]
  }

  App.datatables.create '.datatable.officers', {
    "pageLength": 100,
  }

  App.datatables.create '.datatable.issues', {
    "pageLength": 100,
    "columnDefs": [
      {"width": "20%", "targets": 0},
      {"width": "20%", "targets": 1},
      {"width": "20%", "targets": 3}
    ]
  }

  App.datatables.create '.datatable.projects', {
    "pageLength": 100,
    "order": [[3, "desc"]]
    columnDefs: [
      { type: 'de_date', targets: 2 },
      { type: 'de_date', targets: 3 }
    ]
  }

  App.datatables.create '.datatable.home_pages', {
    "pageLength": 50,
    "order": [[3, "desc"]],
    columnDefs: [
      { type: 'de_date', targets: 2 },
      { type: 'de_date', targets: 3 }
    ]
  }

  App.datatables.create '.datatable.profile_fields', {
    "pageLength": 100,
    "order": [[0, "asc"]]
  }

  App.datatables.create '.datatable.mailing_lists', {
    "pageLength": 100,
    "order": [[0, "asc"]],
    "columnDefs": [
      {"width": "40%", "targets": 0},
      {"width": "20%", "targets": 2}
    ]
  }

  App.datatables.create '.datatable.term_reports', {
    "pageLength": 50,
    "order": [[0, "asc"]],
    columnDefs: [
      { type: 'de_date', targets: 3 }
    ]
  }

  App.datatables.create '.datatable.officers_by_scope', {
    "pageLength": 100,
    "columnDefs": [
      {visible: false, targets: 0},
      {width: "5%", targets: 1},
      {width: "20%", targets: 2},
      {width: "20%", targets: 3},
      {width: "45%", targets: 4},
      {width: "10%", type: 'de_date', targets: 5},
    ],
    "drawCallback": (settings)->
      # Hide the pagination elements if there is only one page.
      if (settings._iDisplayLength > settings.fnRecordsDisplay())
        $(settings.nTableWrapper).find('.dataTables_paginate').hide()
      else
        $(settings.nTableWrapper).find('.dataTables_paginate').show()

      # This callback draws group headers.
      api = @api()
      rows = api.rows(page: 'current').nodes()
      last = null
      api.column(0, page: 'current').data().each (group, i) ->
        if last != group
          $(rows).eq(i).before '<tr class="group scope"><td colspan="5"><div class="group-wrapper">' + group + '</div></td></tr>'
          last = group
        return
  }

  App.datatables.create '.datatable.requests', {
    "pageLength": 100,
    "order": [[2, "desc"]],
    columnDefs: [
      { type: 'de_date', targets: 2 }
    ]
  }

  App.datatables.create '.datatable.corporation_score', {
    "pageLength": 10,
    "order": [[$('.datatable.corporation_score tbody tr:first td').count() - 1, "desc"]],
  }

  App.datatables.create '.datatable.bv_mappings', {
    "pageLength": 25,
    "order": [[2, "asc"], [0, "asc"]]
  }

  App.datatables.create '.datatable.ballots', {
    "pageLength": 50,
    "order": [[0, "desc"]],
    columnDefs: [
      { type: 'de_date', targets: 0 }
    ]
  }

  App.datatables.create '.datatable.officers_by_flag', {
    "pageLength": 500,
    "order": [[0, "asc"]]
  }

  App.datatables.create '.datatable.subscriptions', {
    columnDefs: [
      { type: 'de_date', targets: 5 }
    ]
  }

  App.datatables.create '.datatable.room_occupants', {
    columnDefs: [
      { type: 'de_date', targets: 3 }
    ]
  }

$(document).ready ->
  App.datatables.extend_sort()
  App.datatables.init()



###*
# @summary     HideEmptyColumns
# @description Hide any (or specified) columns if no cells in the column(s)
#              are populated with any values
# @version     1.2.1
# @file        dataTables.hideEmptyColumns.js
# @author      Justin Hyland (http://www.justinhyland.com)
# @contact     j@linux.com
# @copyright   Copyright 2015 Justin Hyland
# @url         https://github.com/jhyland87/DataTables-Hide-Empty-Columns
#
# License      MIT - http://datatables.net/license/mit
#
# Set the column visibility to hidden for any targeted columns that contain nothing
# but null or empty values.
#
#
# Parameters:
#
# -------------
# hideEmptyCols
#      Required:			true
#      Type:				boolean|array|object
#      Aliases:            hideEmptyColumns
#      Description:		Primary setting, either target all columns, or specify an array for a list of cols, or an
#                          object for advanced settings
#      Examples:           hideEmptyCols: true
#                          hideEmptyCols: [ 0, 2, 'age' ]
#                          hideEmptyCols: { columns: [ 0, 2, 'age' ] }
#                          hideEmptyCols: { columns: true }
#
# hideEmptyCols.columns
#      Required:           false
#      Type:               boolean|array
#      Description:        Either true for all columns, or an array of indexes or dataSources
#      Examples:           [ 0, 2, 'age' ]  // Column indexes 0 and 2, and the column name 'age'
#                          true  // All columns
#
# hideEmptyCols.whiteList
#      Required:           false
#      Type:               boolean
#      Default:            true
#      Description:        Specify if the column list is to be targeted, or excluded
#
# hideEmptyCols.trim
#      Required:           false
#      Type:               boolean
#      Default:            true
#      Description:        Determines if column data values should be trimmed before checked for empty values
#
# hideEmptyCols.emptyVals
#      Required:           false
#      Type:               string|number|array|regex
#      Description:        Define one or more values that will be interpreted as "empty"
#      Examples:           [ '<br>', '</br>', '<BR>', '</BR>', '&nbsp;' ]  // HTML Line breaks, and the HTML NBSP char
#                          /\<\/?br\>/i    // Any possible HTML line break character that matches this pattern
#                          ['false', '0', /\<\/?br\>/i]   // The string values 'false' and '0', and all HTML breaks
#
# hideEmptyCols.onStateLoad
#      Required:           false
#      Type:               boolean
#      Default:            true
#      Description:        Determines if the main _checkColumns function should execute after the DT state is loaded
#                          (when the DT stateSave option is enabled). This function will override the column visibility
#                          state in stateSave
#
# hideEmptyCols.perPage
#      Required:           false
#      Type:               boolean
#      Description:        Determine if columns should only be hidden if it has no values on the current page
#
#
# @example
#    // Target all columns - Hide any columns that contain all null/empty values
#    $('#example').DataTable({
#        hideEmptyCols: true
#    })
#
# @example
#    // Target the column indexes 0 & 2
#    $('#example').DataTable({
#        hideEmptyCols: [0,2]
#    })
#
# @example
#    // Target the column with 'age' data source
#    $('#example').DataTable({
#        ajax: 'something.js',
#        hideEmptyCols: ['age'],
#        buttons: [ 'columnsToggle' ],
#        columns: [
#            { name: 'name',     data: 'name' },
#            { name: 'position', data: 'position' },
#            { name: 'age',      data: 'age' }
#        ]
#    })
#
# @example
#    // Target everything *except* the columns 1, 2 & 3
#    $('#example').DataTable({
#        hideEmptyCols: {
#              columns: [ 1, 2, 3 ],
#              whiteList: false
#        }
#    })
#
# @example
#    // Target column indexes 1 and 4, adding custom empty values, and only hide the column if empty on current page
#    $('#example').DataTable({
#        hideEmptyCols: {
#              columns: [ 1, 4 ],
#              perPage: true,
#              emptyVals: [ '0', /(no|false|disabled)/i ]
#        }
#    })
###

'use strict'
((window, document, $) ->
  # On DT Initialization
  $(document).on 'init.dt', (e, dtSettings) ->
    if e.namespace != 'dt'
      return
    # Check for either hideEmptyCols or hideEmptyColumns
    options = dtSettings.oInit.hideEmptyCols or dtSettings.oInit.hideEmptyColumns
    # If neither of the above settings are found, then call it quits
    if !options
      return
    # Helper function to get the value of a config item

    _cfgItem = (item, def) ->
      if $.isPlainObject(options) and typeof options[item] != 'undefined'
        return options[item]
      def

    # Gather all the setting values which will be used
    api = new ($.fn.dataTable.Api)(dtSettings)
    emptyCount = 0
    colList = []
    isWhiteList = !_cfgItem('whiteList', false)
    perPage = _cfgItem('perPage')
    trimData = _cfgItem('trim', true)
    onStateLoad = _cfgItem('onStateLoad', true)
    # Helper function to determine if a cell is empty (including processing custom empty values)

    _isEmpty = (colData) ->
      # Trim the data (unless its set to false)
      if trimData
        colData = $.trim(colData)
      # Basic check
      if colData == null or colData.length == 0
        return true
      # Default to false, any empty matches will reset to true
      retVal = false
      emptyVals = _cfgItem('emptyVals')
      # Internal helper function to check the value against a custom defined empty value (which can be a
      # regex pattern or a simple string)

      _checkEmpty = (val, emptyVal) ->
        objType = Object::toString.call(emptyVal)
        match = objType.match(/^\[object\s(.*)\]$/)
        # If its a regex pattern, then handle it differently
        if match[1] == 'RegExp'
          return val.match(emptyVal)
        # Note: Should this comparison maybe use a lenient/loose comparison operator? hmm..
        val == emptyVal

      # If multiple custom empty values are defined in an array, then check each
      if $.isArray(emptyVals)
        $.each emptyVals, (i, ev) ->
          if _checkEmpty(colData, ev)
            retVal = true
          return
      else if typeof emptyVals != 'undefined'
        if _checkEmpty(colData, emptyVals)
          retVal = true
      retVal

    # If the hideEmptyCols setting is an Array (of column indexes to target)
    if $.isArray(options)
      # And its populated..
      if options.length != 0
        $.each options, (k, i) ->
          # Try to get the real column index from whatever was configured
          indx = api.column(i).index()
          colList.push if typeof indx != 'undefined' then indx else i
          return
      else
        # Otherwise, quit! since its just an empty array
        return
    else if $.isPlainObject(options)
      # If options.columns isnt specifically
      if typeof options.columns == 'undefined' or options.columns == true
        # Set colList to true, enabling every column as a target
        colList = api.columns().indexes().toArray()
      else if $.isArray(options.columns)
        # Otherwise, set the colList
        colList = options.columns
      else if typeof options.columns != 'boolean'
        console.error '[Hide Empty Columns]: Expected typeof `columns` setting value to be an array, boolean or undefined, but received value type "%s"', typeof options.columns
        return
      else
        return
    else if options == true
      # .. Then get the list of all column indexes
      colList = api.columns().indexes().toArray()
    else
      return
    # Function to check the column rows

    _checkColumns = ->
      info = api.page.info()
      colFilter = if perPage then search: 'applied' else undefined
      # Iterate through the table, column by column
      #api.columns({ search: 'applied' }).every(function () {
      api.columns(colFilter).every ->
        emptyCount = 0
        # If the current column is *not* found in the list..
        if $.inArray(@index(), colList) == -1 and $.inArray(api.column(@index()).dataSrc(), colList) == -1
          # .. And the list type is whitelist, then skip this loop
          if isWhiteList == true
            return
        else
          # .. And the list type is blacklist, then skip this loop
          if isWhiteList == false
            return
        # This gets ALL data in current column.. Need just the visible rows
        data = @data().toArray()
        isVis = false
        intStart = if perPage == true and info.serverSide == false then info.start else 0
        intStop = if perPage == true and info.serverSide == false then info.end else data.length
        dtState = api.state.loaded()
        #for( var i = 0; i < data.length; i ++ ) {
        i = intStart
        while i < intStop
          if !_isEmpty(data[i])
            isVis = true
            break
          i++
        # If the # of empty is the same as the length, then no values in col were found
        api.column(@index()).visible isVis
        return
      return

    # If stateSave is enabled in this DT instance, then toggle the column visibility afterwords
    if onStateLoad == true
      api.on 'stateLoadParams.dt', _checkColumns
    # If were checking for each page, then attach functions to any events that may introduce or remove new
    # columns/rows from the table (page, order, search and length)
    if perPage == true
      api.on('page.dt', _checkColumns).on('search.dt', _checkColumns).on('order.dt', _checkColumns).on('length.dt', _checkColumns).on 'draw.dt', _checkColumns
    # triggers after data loaded with AJAX
    # Run check for the initial page load
    _checkColumns()
    return
  return
) window, document, jQuery

# ---
# generated by js2coffee 2.2.0