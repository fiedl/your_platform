# Turbolinks Loading Spinner
# Source: https://gist.github.com/cpuguy83/5016442

@PageSpinner =
  spin: (ms=500)->
    @spinner = setTimeout( (=> @add_spinner()), ms)
    $(document).on 'page:change', =>
      @remove_spinner()
  spinner_html: '
    <div class="modal hide fade" id="page-spinner">
      <div class="modal-head card-title">Please Wait...</div>
      <div class="modal-body card-body">
        <i class="icon-spinner icon-spin icon-2x"></i>
        &emsp;Loading...
      </div>
    </div>
  '
  spinner: null
  add_spinner: ->
    $('body').append(@spinner_html)
    $('body div#page-spinner').modal()
  remove_spinner: ->
    clearTimeout(@spinner)
    $('div#page-spinner').modal('hide')
    $('div#page-spinner').on 'hidden', ->
      $(this).remove()

$(document).on 'page:fetch', ->
  PageSpinner.spin()
