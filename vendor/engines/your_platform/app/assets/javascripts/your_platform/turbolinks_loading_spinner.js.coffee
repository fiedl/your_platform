# Turbolinks Loading Spinner
# Source: https://gist.github.com/cpuguy83/5016442

@PageSpinner =
  spin: (ms=500)->
    @spinner = setTimeout( (=> @add_spinner()), ms)
    $(document).on 'page:change', =>
      @remove_spinner()
  icon:
    if ((new Date).getHours() > 18)
      "icon-beer"
    else
      "icon-coffee"
  spinner_html: '
    <div class="modal hide fade" id="page-spinner">
      <div class="modal-header card-title"><h3>Wingolfsplattform</h3></div>
      <div class="modal-body card-body">
        <!--i class="icon-spinner icon-spin icon-2x"></i-->
        <i class="' + @icon + ' icon-2x"></i>
        &emsp;Inhalt wird geladen. Bitte kurz warten ...
      </div>
    </div>
  '
  spinner: null
  add_spinner: ->
    alert(@icon)
    $('body').append(@spinner_html)
    $('body div#page-spinner').modal({keyboard: false})
  remove_spinner: ->
    clearTimeout(@spinner)
    $('div#page-spinner').modal('hide')
    $('div#page-spinner').on 'hidden', ->
      $(this).remove()

$(document).on 'page:fetch', ->
  PageSpinner.spin()
