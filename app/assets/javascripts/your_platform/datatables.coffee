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
          "sFirst":      "Erste",
          "sPrevious":   "Vorige",
          "sNext":       "Nächste",
          "sLast":       "Letzte"
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
      "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
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

  adjust_css: ->
    # Modify the datatable filter bar.
    $('.dataTables_filter label input')
     .attr('placeholder', I18n.t('type_to_filter_table'))
     .addClass('form-control')

  create: (selector, options)->
    if $(selector).count() > 0
      unless $.fn.dataTable.isDataTable(selector)
        if $(selector).parents('.dataTables_wrapper').count() == 0
          configuration = {}
          $.extend configuration, App.datatables.common_configuration()
          $.extend configuration, options
          $(selector).dataTable(configuration)
          App.datatables.adjust_css()
}

$(document).ready ->
  App.datatables.extend_sort()

  App.datatables.create '.datatable.members', {
    "pageLength": 20,
    "order": [[3, "desc"]],
    columnDefs: [
      {width: "15%", type: 'de_date', targets: 3}
    ]
  }

  App.datatables.create '.datatable.activities', {
    "pageLength": 100,
    "order": [[0, "desc"]],
    "columnDefs": [
      {width: "50%", targets: 4}
    ]
  }

  App.datatables.create '.datatable.members', {
    "pageLength": 20,
    "order": [[3, "desc"]],
    columnDefs: [
      {width: "15%", type: 'de_date', targets: 3}
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

  App.datatables.create '.datatable.memberships', {
    "pageLength": 100,
    columnDefs: [
      { type: 'de_date', targets: 3 },
      { type: 'de_date', targets: 4 }
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