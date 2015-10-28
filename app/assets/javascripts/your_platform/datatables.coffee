$(document).ready ->
  
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
  
  
  language_options = ->
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
 
  common_configuration = {
    "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    "sPaginationType": "full_numbers",
    "bJQueryUI": true,
    "lengthMenu": [ 10, 20, 50, 100, 1000 ],
    "language": language_options(),
    "drawCallback": (settings)->
      # Hide the pagination elements if there is only one page.
      if (settings._iDisplayLength > settings.fnRecordsDisplay())
        $(settings.nTableWrapper).find('.dataTables_paginate').hide()
      else
        $(settings.nTableWrapper).find('.dataTables_paginate').show()
  }
  
  $('.datatable.activities').dataTable(jQuery.extend({
    "pageLength": 100,
    "order": [[0, "desc"]]
  }, common_configuration))
  $('.datatable.members').dataTable(jQuery.extend({
    "pageLength": 20,
    "order": [[3, "desc"]],
    columnDefs: [
      { type: 'de_date', targets: 3}
    ]
  }, common_configuration))
  $('.datatable.groups').dataTable(jQuery.extend({
    "order": [[0, "asc"]],
    "pageLength": 100
  }, common_configuration))
  $('.datatable.events').dataTable(jQuery.extend({
    "order": [[1, "desc"]],
    "pageLength": 100,
    columnDefs: [
      { type: 'de_date', targets: 1}
    ]
  }, common_configuration))
  $('.datatable.statistics').dataTable(jQuery.extend({
    "pageLength": 100,
    "order": [[0, "asc"]]
  }, common_configuration))
  $('.datatable.memberships').dataTable(jQuery.extend({
    "pageLength": 100,
    columnDefs: [
      { type: 'de_date', targets: 3 },
      { type: 'de_date', targets: 4 }
    ]
  }, common_configuration))
  $('.datatable.officers').dataTable(jQuery.extend({
    "pageLength": 100,
  }, common_configuration))
  $('.datatable.issues').dataTable(jQuery.extend({
    "pageLength": 100,
    "columnDefs": [
      {"width": "25%", "targets": 1},
      {"width": "25%", "targets": 2}
    ]
  }, common_configuration))
  $('.datatable.projects').dataTable(jQuery.extend({
    "pageLength": 100,
    "order": [[3, "desc"]]
    columnDefs: [
      { type: 'de_date', targets: 2 },
      { type: 'de_date', targets: 3 }
    ]
  }, common_configuration))
  
  # Insert above.
  # This modified the common_configuration:
  $('.datatable.officers_by_scope').dataTable(jQuery.extend(common_configuration, {
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
  }))
  
  
  
  # Modify the datatable filter bar.
  $('.dataTables_filter label input')
    .attr('placeholder', I18n.t('type_to_filter_table'))
    .addClass('form-control')
  