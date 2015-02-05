# Turbolinks Loading Spinner
# Source: https://gist.github.com/cpuguy83/5016442

@PageSpinner =
  spin: (ms=500)->
    @spinner = setTimeout( (=> @add_spinner()), ms)
    $(document).on 'page:change', =>
      @remove_spinner()
  icon: ->
    if ((new Date).getHours() > 18)
      "beer"
    else
      "coffee"
  title: ->
    str = $('title').text()  # "My Page - Your Platform"
    second_str = str.split(" - ")[1]
    second_str || str
  spinner_html: (icon, title)-> '
    <div class="modal hide fade" id="page-spinner">
      <div class="modal-header card-title"><h3>' + title + '</h3></div>
      <div class="modal-body card-body">
        <span class="glyphicon glyphicon-' + icon + '" aria-hidden="true"></span>
        &emsp;Inhalt wird geladen. Bitte warten ...
      </div>
    </div>
  '
  spinner: null
  add_spinner: ->
    $('body').append(@spinner_html(@icon(), @title()))
    $('body div#page-spinner').modal({keyboard: false, backdrop: 'static'})
    $('body div#page-spinner').css('z-index', '-1')
    setTimeout( ->
      $('body div#page-spinner').hide().css('z-index', 1500).show('fade')
    , 2000)
  remove_spinner: ->
    clearTimeout(@spinner)
    $('div#page-spinner').modal('hide')
    $('div#page-spinner').on 'hidden', ->
      $(this).remove()

$(document).on 'page:fetch', ->
  PageSpinner.spin()
