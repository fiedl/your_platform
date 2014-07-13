ready = ->
  
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
        "sSearch":         "Suchen",
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
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "lengthMenu": [ 10, 20, 50, 100, 1000 ],
    "pageLength": 20,
    "language": language_options()
  }
  
  $('.datatable.activities').dataTable(jQuery.extend({
    "order": [[0, "desc"]]
  }, common_configuration))
  $('.datatable.members').dataTable(jQuery.extend({
    "order": [[0, "asc"]],
    columnDefs: [
      { type: 'de_date', targets: 3}
    ]
  }, common_configuration))
  
$(document).ready(ready)
$(document).on('page:load', ready)
