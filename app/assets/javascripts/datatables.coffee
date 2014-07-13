ready = ->
  language_options = ->
    if $('body').data('locale') == 'de'
      {
        "sEmptyTable":     "Keine Daten in der Tabelle vorhanden",
        "sInfo":           "_START_ bis _END_ von _TOTAL_ Einträgen",
        "sInfoEmpty":      "0 bis 0 von 0 Einträgen",
        "sInfoFiltered":   "(gefiltert von _MAX_ Einträgen)",
        "sInfoPostFix":    "",
        "sInfoThousands":    ".",
        "sLengthMenu":     "_MENU_ Einträge anzeigen",
        "sLoadingRecords":   "Wird geladen...",
        "sProcessing":     "Bitte warten...",
        "sSearch":         "Suchen",
        "sZeroRecords":    "Keine Einträge vorhanden.",
        "oPaginate": {
          "sFirst":      "Erste",
          "sPrevious":   "Zurück",
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
    "order": [[0, "asc"]]
  }, common_configuration))
  
$(document).ready(ready)
$(document).on('page:load', ready)
